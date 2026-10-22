import 'package:cloud_firestore/cloud_firestore.dart';

typedef Doc = Map<String, dynamic>;

/// Wrapper sans état autour de Firestore ; chaque document renvoyé contient son id sous la clé `id`.
class FirestoreService {
  FirestoreService(this._db);

  final FirebaseFirestore _db;

  Doc _withId(DocumentSnapshot<Doc> doc) => {...doc.data()!, 'id': doc.id};

  Future<List<Doc>> list(String path) async {
    final snapshot = await _db.collection(path).get();
    return snapshot.docs.map(_withId).toList();
  }

  Future<Doc?> get(String path, String id) async {
    final doc = await _db.collection(path).doc(id).get();
    return doc.exists ? _withId(doc) : null;
  }

  Future<Doc?> findFirst(String path, Map<String, Object> where) async {
    Query<Doc> query = _db.collection(path);
    where.forEach(
      (field, value) => query = query.where(field, isEqualTo: value),
    );
    final snapshot = await query.limit(1).get();
    return snapshot.docs.isEmpty ? null : _withId(snapshot.docs.first);
  }

  Future<String> add(String path, Doc data) async {
    final ref = await _db.collection(path).add(data);
    return ref.id;
  }

  Future<void> set(String path, String id, Doc data) =>
      _db.collection(path).doc(id).set(data);

  Future<void> delete(String path, String id) =>
      _db.collection(path).doc(id).delete();
}
