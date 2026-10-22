import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'data/repositories/activity_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/firestore_service.dart';
import 'data/services/seed_service.dart';
import 'firebase_options.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final service = FirestoreService(FirebaseFirestore.instance);
  if (kDebugMode) {
    SeedService(service)
        .seedIfEmpty()
        .catchError((Object e) => debugPrint('Seed impossible : $e'));
  }

  final activityRepository = ActivityRepository(service: service);
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: UserRepository(service: service)),
        Provider.value(value: activityRepository),
        Provider.value(
          value: CartRepository(
            service: service,
            activityRepository: activityRepository,
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
