import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp2_activites/data/repositories/activity_repository.dart';
import 'package:tp2_activites/data/repositories/cart_repository.dart';
import 'package:tp2_activites/data/repositories/user_repository.dart';
import 'package:tp2_activites/data/services/firestore_service.dart';
import 'package:tp2_activites/data/services/seed_service.dart';

void main() {
  late FirestoreService service;
  late UserRepository users;
  late ActivityRepository activities;
  late CartRepository cart;

  setUp(() async {
    service = FirestoreService(FakeFirebaseFirestore());
    users = UserRepository(service: service);
    activities = ActivityRepository(service: service);
    cart = CartRepository(service: service, activityRepository: activities);
    await SeedService(service).seedIfEmpty();
  });

  test('login renvoie l\'utilisateur pour de bons identifiants', () async {
    final user = await users.login('alice', 'alice123');
    expect(user?.id, 'u1');
    expect(user?.city, 'Paris');
  });

  test('login renvoie null pour de mauvais identifiants', () async {
    expect(await users.login('alice', 'faux'), isNull);
    expect(await users.login('', ''), isNull);
  });

  test('le seed est idempotent et expose 6 activités', () async {
    await SeedService(service).seedIfEmpty();
    expect(await activities.getActivities(), hasLength(6));
  });

  test('le panier ajoute et retire des activités', () async {
    await cart.add('u1', 'a1');
    await cart.add('u1', 'a3');
    expect((await cart.getCart('u1')).map((a) => a.id), ['a1', 'a3']);

    await cart.remove('u1', 'a1');
    expect((await cart.getCart('u1')).map((a) => a.id), ['a3']);
  });

  test('updateProfile persiste les modifications', () async {
    final user = (await users.getUser('u2'))!;
    await users.updateProfile(user.copyWith(city: 'Nantes'));
    expect((await users.getUser('u2'))?.city, 'Nantes');
  });
}
