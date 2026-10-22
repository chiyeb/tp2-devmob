import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_service.dart';

/// Insère des données de démo si la base est vide (comptes de test : alice/alice123, bob/bob123).
class SeedService {
  SeedService(this._service);

  final FirestoreService _service;

  static String _image(String seed) =>
      'https://picsum.photos/seed/$seed/600/400';

  Future<void> seedIfEmpty() async {
    if ((await _service.list('users')).isNotEmpty) return;

    final users = {
      'u1': {
        'login': 'alice',
        'password': 'alice123',
        'birthday': Timestamp.fromDate(DateTime(2000, 5, 12)),
        'address': '12 rue des Lilas',
        'postalCode': '75011',
        'city': 'Paris',
      },
      'u2': {
        'login': 'bob',
        'password': 'bob123',
        'birthday': Timestamp.fromDate(DateTime(1998, 11, 3)),
        'address': '4 avenue Foch',
        'postalCode': '69006',
        'city': 'Lyon',
      },
    };
    final activities = {
      'a1': ['Initiation à l\'escalade', 'Sport', 'Paris', 8, 25.0],
      'a2': ['Journée shopping', 'Shopping', 'Lyon', 4, 10.0],
      'a3': ['Visite du Louvre', 'Culture', 'Paris', 15, 17.5],
      'a4': ['Cours de yoga', 'Détente', 'Bordeaux', 12, 12.0],
      'a5': ['Randonnée en forêt', 'Sport', 'Fontainebleau', 20, 0.0],
      'a6': ['Atelier de cuisine', 'Gastronomie', 'Marseille', 6, 45.0],
    };

    for (final entry in users.entries) {
      await _service.set('users', entry.key, entry.value);
    }
    for (final entry in activities.entries) {
      final [title, category, location, maxPeople, price] = entry.value;
      await _service.set('activities', entry.key, {
        'title': title,
        'imageUrl': _image(entry.key),
        'category': category,
        'location': location,
        'maxPeople': maxPeople,
        'price': price,
      });
    }
  }
}
