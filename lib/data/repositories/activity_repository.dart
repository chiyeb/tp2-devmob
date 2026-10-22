import '../../domain/models/activity.dart';
import '../services/firestore_service.dart';

class ActivityRepository {
  ActivityRepository({required this._service});

  static const _path = 'activities';

  final FirestoreService _service;

  Future<List<Activity>> getActivities() async {
    final docs = await _service.list(_path);
    return docs.map(_fromDoc).toList();
  }

  Future<Activity?> getActivity(String id) async {
    final doc = await _service.get(_path, id);
    return doc == null ? null : _fromDoc(doc);
  }

  Activity _fromDoc(Doc doc) => Activity(
    id: doc['id'] as String,
    title: doc['title'] as String,
    imageUrl: doc['imageUrl'] as String,
    category: doc['category'] as String,
    location: doc['location'] as String,
    maxPeople: (doc['maxPeople'] as num).toInt(),
    price: (doc['price'] as num).toDouble(),
  );
}
