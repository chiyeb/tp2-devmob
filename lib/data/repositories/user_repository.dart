import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/app_user.dart';
import '../services/firestore_service.dart';

class UserRepository {
  UserRepository({required this._service});

  static const _path = 'users';

  final FirestoreService _service;

  /// Renvoie l'utilisateur correspondant aux identifiants, ou null s'il n'existe pas.
  Future<AppUser?> login(String login, String password) async {
    final doc = await _service.findFirst(_path, {
      'login': login,
      'password': password,
    });
    return doc == null ? null : _fromDoc(doc);
  }

  Future<AppUser?> getUser(String id) async {
    final doc = await _service.get(_path, id);
    return doc == null ? null : _fromDoc(doc);
  }

  Future<void> updateProfile(AppUser user) => _service.set(_path, user.id, {
    'login': user.login,
    'password': user.password,
    'birthday': user.birthday == null
        ? null
        : Timestamp.fromDate(user.birthday!),
    'address': user.address,
    'postalCode': user.postalCode,
    'city': user.city,
  });

  AppUser _fromDoc(Doc doc) => AppUser(
    id: doc['id'] as String,
    login: doc['login'] as String,
    password: doc['password'] as String,
    birthday: (doc['birthday'] as Timestamp?)?.toDate(),
    address: doc['address'] as String? ?? '',
    postalCode: doc['postalCode'] as String? ?? '',
    city: doc['city'] as String? ?? '',
  );
}
