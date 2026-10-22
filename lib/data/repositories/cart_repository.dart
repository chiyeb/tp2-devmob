import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/activity.dart';
import '../services/firestore_service.dart';
import 'activity_repository.dart';

class CartRepository {
  CartRepository({required this._service, required this._activityRepository});

  final FirestoreService _service;
  final ActivityRepository _activityRepository;

  String _path(String userId) => 'users/$userId/cart';

  Future<List<Activity>> getCart(String userId) async {
    final entries = await _service.list(_path(userId));
    final activities = await Future.wait(
      entries.map((e) => _activityRepository.getActivity(e['id'] as String)),
    );
    return activities.whereType<Activity>().toList();
  }

  Future<void> add(String userId, String activityId) => _service.set(
    _path(userId),
    activityId,
    {'addedAt': FieldValue.serverTimestamp()},
  );

  Future<void> remove(String userId, String activityId) =>
      _service.delete(_path(userId), activityId);
}
