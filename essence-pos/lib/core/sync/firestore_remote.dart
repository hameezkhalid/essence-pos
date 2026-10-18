import 'package:cloud_firestore/cloud_firestore.dart';

import 'remote_store.dart';

/// Firestore layout: /stores/{storeId}/{collection}/{docId}
class FirestoreRemote implements RemoteStore {
  FirestoreRemote(this.db, this.storeId);

  final FirebaseFirestore db;
  @override
  final String storeId;

  DocumentReference<Map<String, dynamic>> get storeDoc => db.collection('stores').doc(storeId);
  CollectionReference<Map<String, dynamic>> col(String c) => storeDoc.collection(c);

  /// Security rules check store membership with one `get()` per write, and Firestore caps
  /// access calls at 20 per batched write — so commit in small batches, several at a time.
  static const _chunk = 15;
  static const _parallel = 6;

  @override
  Future<void> writeBatch(List<RemoteWrite> writes) async {
    final chunks = <List<RemoteWrite>>[
      for (var i = 0; i < writes.length; i += _chunk) writes.sublist(i, i + _chunk > writes.length ? writes.length : i + _chunk),
    ];
    for (var i = 0; i < chunks.length; i += _parallel) {
      await Future.wait([
        for (final c in chunks.skip(i).take(_parallel))
          () {
            final batch = db.batch();
            for (final w in c) {
              batch.set(col(w.collection).doc(w.docId), {...w.data, 'syncedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
            }
            return batch.commit();
          }(),
      ]);
    }
  }

  @override
  Stream<List<RemoteChange>> watch(String collection, {required int sinceMs}) {
    Query<Map<String, dynamic>> q = col(collection);
    if (sinceMs > 0) {
      q = q.where('syncedAt', isGreaterThanOrEqualTo: Timestamp.fromMillisecondsSinceEpoch(sinceMs));
    }
    return q.snapshots().map((snap) {
      final out = <RemoteChange>[];
      for (final c in snap.docChanges) {
        // Our own pending writes come back as local echoes; the outbox already has them.
        if (c.doc.metadata.hasPendingWrites) continue;
        final data = c.doc.data() ?? {};
        final ts = data['syncedAt'];
        out.add(RemoteChange(
          c.type == DocumentChangeType.removed ? RemoteChangeType.removed : RemoteChangeType.upsert,
          c.doc.id,
          data,
          ts is Timestamp ? ts.millisecondsSinceEpoch : null,
        ));
      }
      return out;
    });
  }

  @override
  Future<void> writeDerived(String collection, String docId, Map<String, dynamic> data) =>
      col(collection).doc(docId).set({...data, 'syncedAt': FieldValue.serverTimestamp()});

  @override
  Future<int> deleteAll(String collection) async {
    var n = 0;
    while (true) {
      final snap = await col(collection).limit(400).get();
      if (snap.docs.isEmpty) break;
      for (var i = 0; i < snap.docs.length; i += _chunk) {
        final b = db.batch();
        for (final d in snap.docs.skip(i).take(_chunk)) {
          b.delete(d.reference);
        }
        await b.commit();
      }
      n += snap.docs.length;
    }
    return n;
  }

  @override
  Future<void> setNetworkEnabled(bool enabled) => enabled ? db.enableNetwork() : db.disableNetwork();

  // ───────────── Store membership ─────────────

  /// Checks this account's access. [StoreClaim.created] means the store is new (no data yet) and
  /// this terminal should set it up; [StoreClaim.member] means it already has data to download.
  /// If the store document doesn't exist, the signed-in account claims it as admin.
  Future<StoreClaim> claimOrJoin(String uid, String email) async {
    final DocumentSnapshot<Map<String, dynamic>> snap;
    try {
      snap = await storeDoc.get(const GetOptions(source: Source.server));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return StoreClaim.denied;
      rethrow;
    }
    if (!snap.exists) {
      await storeDoc.set({
        'memberUids': [uid],
        'adminUids': [uid],
        'ownerEmail': email,
        'accounts': {
          uid: {'email': email, 'role': 'admin', 'name': 'Admin'},
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
      return StoreClaim.created;
    }
    final members = (snap.data()?['memberUids'] as List?)?.cast<String>() ?? const [];
    if (!members.contains(uid)) return StoreClaim.denied;
    final settings = await col('settings').doc('store').get(const GetOptions(source: Source.server));
    return settings.exists ? StoreClaim.member : StoreClaim.created;
  }

  Stream<StoreAccess> watchAccess() => storeDoc.snapshots().map(StoreAccess.fromDoc);

  /// Adds a login (created with [AccountAdmin.createLogin]) to the store. Admins only.
  Future<void> addAccount({required String uid, required String email, required String name, required bool admin}) =>
      storeDoc.update({
        'memberUids': FieldValue.arrayUnion([uid]),
        'adminUids': admin ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]),
        'accounts.$uid': {'email': email, 'name': name, 'role': admin ? 'admin' : 'till'},
      });

  Future<void> setAdmin(String uid, bool admin) => storeDoc.update({
        'adminUids': admin ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]),
        'accounts.$uid.role': admin ? 'admin' : 'till',
      });

  /// Removes a login's access to the store (the login itself remains but can't open anything).
  Future<void> removeAccount(String uid) => storeDoc.update({
        'memberUids': FieldValue.arrayRemove([uid]),
        'adminUids': FieldValue.arrayRemove([uid]),
        'accounts.$uid': FieldValue.delete(),
      });
}

enum StoreClaim { created, member, denied }

class StoreAccount {
  const StoreAccount({required this.uid, required this.email, required this.name, required this.admin});
  final String uid;
  final String email;
  final String name;
  final bool admin;
}

/// Who can sign in to the store, from the store document.
class StoreAccess {
  const StoreAccess({this.memberUids = const [], this.adminUids = const [], this.accounts = const []});
  final List<String> memberUids;
  final List<String> adminUids;
  final List<StoreAccount> accounts;

  bool isAdmin(String? uid) => uid != null && adminUids.contains(uid);

  static StoreAccess fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data() ?? const {};
    final members = (data['memberUids'] as List?)?.cast<String>() ?? const <String>[];
    final admins = (data['adminUids'] as List?)?.cast<String>() ?? const <String>[];
    final acc = (data['accounts'] as Map?) ?? const {};
    return StoreAccess(
      memberUids: members,
      adminUids: admins,
      accounts: [
        for (final uid in members)
          StoreAccount(
            uid: uid,
            email: (acc[uid] as Map?)?['email'] as String? ?? '(unknown login)',
            name: (acc[uid] as Map?)?['name'] as String? ?? '',
            admin: admins.contains(uid),
          ),
      ],
    );
  }
}
