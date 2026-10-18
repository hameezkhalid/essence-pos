/// A document write going to the cloud.
class RemoteWrite {
  const RemoteWrite(this.collection, this.docId, this.data);
  final String collection;
  final String docId;
  final Map<String, dynamic> data;
}

enum RemoteChangeType { upsert, removed }

/// A change coming from the cloud.
class RemoteChange {
  const RemoteChange(this.type, this.docId, this.data, this.syncedAtMs);
  final RemoteChangeType type;
  final String docId;
  final Map<String, dynamic> data;

  /// Server time the document was last written (for pull cursors).
  final int? syncedAtMs;
}

/// The cloud side of sync. The POS never talks to Firestore directly; it goes through this,
/// so the transport can be swapped (e.g. REST) and sync can be tested without Firebase.
abstract class RemoteStore {
  String get storeId;

  /// Writes documents (set-merge, idempotent) and stamps each with a server `syncedAt`.
  Future<void> writeBatch(List<RemoteWrite> writes);

  /// Streams changes to [collection] for documents synced at or after [sinceMs].
  Stream<List<RemoteChange>> watch(String collection, {required int sinceMs});

  /// Writes a derived document that isn't mirrored locally (e.g. live stock summary).
  Future<void> writeDerived(String collection, String docId, Map<String, dynamic> data);

  /// Deletes every document in [collection] (demo reset only).
  Future<int> deleteAll(String collection);

  Future<void> setNetworkEnabled(bool enabled);
}
