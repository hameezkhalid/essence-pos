import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../db/database.dart';
import 'remote_store.dart';

class SyncStatus {
  const SyncStatus({
    this.networkUp = true,
    this.forcedOffline = false,
    this.pending = 0,
    this.syncing = false,
    this.lastSyncAt,
    this.error,
  });

  final bool networkUp;
  final bool forcedOffline;
  final int pending;
  final bool syncing;
  final DateTime? lastSyncAt;
  final String? error;

  bool get online => networkUp && !forcedOffline;

  SyncStatus copyWith({bool? networkUp, bool? forcedOffline, int? pending, bool? syncing, DateTime? lastSyncAt, String? error, bool clearError = false}) =>
      SyncStatus(
        networkUp: networkUp ?? this.networkUp,
        forcedOffline: forcedOffline ?? this.forcedOffline,
        pending: pending ?? this.pending,
        syncing: syncing ?? this.syncing,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Offline-first sync between the local SQLite database and the cloud.
///
/// * Push: every local write is queued in `outbox` in the same transaction as the write.
///   The queue is sent in order, in batches; each write is an idempotent set, so retries
///   can't create duplicates.
/// * Pull: one live listener per collection upserts incoming documents into SQLite
///   (last-write-wins on `updatedAt`). The UI only reads SQLite, so it updates instantly.
class SyncEngine {
  SyncEngine(this.db, this.remote, {this.networkStream, this.pushInterval = const Duration(seconds: 15)});

  final AppDatabase db;
  final RemoteStore remote;
  /// Overrides OS connectivity (tests).
  final Stream<bool>? networkStream;
  final Duration pushInterval;

  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _current = const SyncStatus();
  SyncStatus get status => _current;
  Stream<SyncStatus> get statusStream async* {
    yield _current;
    yield* _status.stream;
  }

  final _subs = <StreamSubscription<dynamic>>[];
  final _pullSubs = <StreamSubscription<dynamic>>[];
  Timer? _timer;
  Timer? _debounce;
  bool _pumping = false;
  bool _started = false;
  int _failures = 0;
  DateTime _retryAfter = DateTime.fromMillisecondsSinceEpoch(0);

  void _emit(SyncStatus s) {
    _current = s;
    if (!_status.isClosed) _status.add(s);
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    final forced = await db.getMeta('sync.forcedOffline') == 'true';
    _emit(_current.copyWith(forcedOffline: forced));
    if (forced) await _safe(() => remote.setNetworkEnabled(false));

    _subs.add(db.watchOutboxCount().listen((n) {
      _emit(_current.copyWith(pending: n));
      if (n > 0) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 250), pump);
      }
    }));

    final net = networkStream ?? _connectivity();
    _subs.add(net.listen((up) {
      final was = _current.networkUp;
      _emit(_current.copyWith(networkUp: up));
      if (up && !was) {
        _retryAfter = DateTime.fromMillisecondsSinceEpoch(0);
        pump();
      }
    }));

    _timer = Timer.periodic(pushInterval, (_) => pump());
    _startPull();
    unawaited(pump());
  }

  Stream<bool> _connectivity() {
    final c = Connectivity();
    bool up(List<ConnectivityResult> r) => r.any((x) => x != ConnectivityResult.none);
    final ctrl = StreamController<bool>();
    c.checkConnectivity().then((r) => ctrl.add(up(r))).catchError((_) => ctrl.add(true));
    final sub = c.onConnectivityChanged.listen((r) => ctrl.add(up(r)), onError: (_) {});
    ctrl.onCancel = sub.cancel;
    return ctrl.stream;
  }

  /// Demo switch: behave as if the internet is down.
  Future<void> setForcedOffline(bool offline) async {
    await db.setMeta('sync.forcedOffline', '$offline');
    _emit(_current.copyWith(forcedOffline: offline));
    await _safe(() => remote.setNetworkEnabled(!offline));
    if (!offline) {
      _retryAfter = DateTime.fromMillisecondsSinceEpoch(0);
      _restartPull();
      await pump();
    }
  }

  /// Sends queued writes to the cloud, oldest first.
  Future<void> pump() async {
    if (_pumping || !_started || !_current.online) return;
    if (DateTime.now().isBefore(_retryAfter)) return;
    _pumping = true;
    _emit(_current.copyWith(syncing: true));
    try {
      while (true) {
        final batch = await (db.select(db.outbox)
              ..orderBy([(t) => OrderingTerm.asc(t.seq)])
              ..limit(400))
            .get();
        if (batch.isEmpty) break;
        // Each entry is a full row, so only the latest version of a document needs sending.
        final latest = <String, RemoteWrite>{};
        for (final e in batch) {
          final spec = db.specByCollection[e.collection];
          final local = jsonDecode(e.payload) as Map<String, dynamic>;
          final key = '${e.collection}/${e.docId}';
          latest.remove(key);
          latest[key] = RemoteWrite(e.collection, e.docId, spec?.toRemote(local) ?? local);
        }
        await remote.writeBatch(latest.values.toList()).timeout(const Duration(seconds: 60));
        await (db.delete(db.outbox)..where((t) => t.seq.isSmallerOrEqualValue(batch.last.seq))).go();
        _failures = 0;
        _emit(_current.copyWith(lastSyncAt: DateTime.now(), clearError: true));
      }
    } catch (e) {
      _failures++;
      final wait = Duration(seconds: (2 << (_failures.clamp(1, 6))).toInt());
      _retryAfter = DateTime.now().add(wait);
      _emit(_current.copyWith(error: _describe(e)));
      try {
        final first = await (db.select(db.outbox)
              ..orderBy([(t) => OrderingTerm.asc(t.seq)])
              ..limit(1))
            .getSingleOrNull();
        if (first != null) {
          await (db.update(db.outbox)..where((t) => t.seq.equals(first.seq)))
              .write(OutboxCompanion(attempts: Value(first.attempts + 1), lastError: Value(_describe(e))));
        }
      } catch (_) {}
    } finally {
      _pumping = false;
      _emit(_current.copyWith(syncing: false));
    }
  }

  void _startPull() {
    for (final spec in db.syncSpecs) {
      _listen(spec);
    }
  }

  void _restartPull() {
    for (final s in _pullSubs) {
      s.cancel();
    }
    _pullSubs.clear();
    _startPull();
  }

  Future<void> _listen(SyncSpec spec) async {
    final key = 'pull.${spec.collection}';
    final cursor = int.tryParse(await db.getMeta(key) ?? '') ?? 0;
    // Re-read a minute of overlap: upserts are idempotent, so overlap is harmless.
    final since = cursor > 60000 ? cursor - 60000 : 0;
    final sub = remote.watch(spec.collection, sinceMs: since).listen(
      (changes) => _apply(spec, key, changes),
      onError: (Object e) {
        _emit(_current.copyWith(error: _describe(e)));
        // Retry the listener later (e.g. permission or network errors).
        Timer(const Duration(seconds: 30), () {
          if (_started) _listen(spec);
        });
      },
    );
    _pullSubs.add(sub);
  }

  Future<void> _apply(SyncSpec spec, String cursorKey, List<RemoteChange> changes) async {
    if (changes.isEmpty) return;
    var maxSynced = 0;
    await db.transaction(() async {
      for (final c in changes) {
        if (c.syncedAtMs != null && c.syncedAtMs! > maxSynced) maxSynced = c.syncedAtMs!;
        if (c.type == RemoteChangeType.removed) {
          await db.customStatement('DELETE FROM ${spec.table.actualTableName} WHERE id = ?', [c.docId]);
          continue;
        }
        try {
          final local = spec.fromRemote(c.data)..['id'] = c.docId;
          final updatedAt = (local['updatedAt'] as num?)?.toInt() ?? 0;
          local['updatedAt'] = updatedAt;
          local['deleted'] ??= false;
          if (await spec.isNewer(db, c.docId, updatedAt)) {
            await spec.upsert(db, local);
          }
        } catch (e) {
          debugPrint('sync: skipped ${spec.collection}/${c.docId}: $e');
        }
      }
    });
    if (maxSynced > 0) {
      final prev = int.tryParse(await db.getMeta(cursorKey) ?? '') ?? 0;
      if (maxSynced > prev) await db.setMeta(cursorKey, '$maxSynced');
    }
    _emit(_current.copyWith(lastSyncAt: DateTime.now(), clearError: true));
  }

  /// Forgets pull cursors so the next start downloads everything again.
  Future<void> resetCursors() async {
    for (final s in db.syncSpecs) {
      await db.setMeta('pull.${s.collection}', '0');
    }
  }

  Future<void> stop() async {
    _started = false;
    _timer?.cancel();
    _debounce?.cancel();
    for (final s in [..._subs, ..._pullSubs]) {
      unawaited(s.cancel());
    }
    _subs.clear();
    _pullSubs.clear();
  }

  Future<void> dispose() async {
    await stop();
    await _status.close();
  }

  Future<void> _safe(Future<void> Function() f) async {
    try {
      await f();
    } catch (_) {}
  }

  static String _describe(Object e) {
    final s = e.toString();
    if (s.contains('permission-denied')) return 'Permission denied: this account is not a member of the store';
    if (e is TimeoutException) return 'Server not reachable';
    return s.length > 160 ? '${s.substring(0, 160)}…' : s;
  }
}
