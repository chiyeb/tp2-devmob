import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp2_activites/data/repositories/user_repository.dart';
import 'package:tp2_activites/data/services/firestore_service.dart';
import 'package:tp2_activites/data/services/seed_service.dart';
import 'package:tp2_activites/domain/models/app_user.dart';
import 'package:tp2_activites/ui/features/auth/view_models/login_view_model.dart';
import 'package:tp2_activites/ui/features/auth/views/login_view.dart';
import 'package:tp2_activites/ui/features/home/views/home_view.dart';

class _FailingUserRepository extends UserRepository {
  _FailingUserRepository(FirestoreService service) : super(service: service);

  @override
  Future<AppUser?> login(String login, String password) =>
      throw Exception('réseau indisponible');
}

void main() {
  late FirestoreService service;

  setUp(() async {
    service = FirestoreService(FakeFirebaseFirestore());
    await SeedService(service).seedIfEmpty();
  });

  Future<void> pumpLogin(WidgetTester tester, UserRepository repository) {
    return tester.pumpWidget(
      MaterialApp(
        home: LoginView(viewModel: LoginViewModel(userRepository: repository)),
      ),
    );
  }

  Future<void> submit(
    WidgetTester tester, {
    String? login,
    String? password,
  }) async {
    if (login != null) {
      await tester.enterText(find.widgetWithText(TextField, 'Login'), login);
    }
    if (password != null) {
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        password,
      );
    }
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
  }

  testWidgets('affiche AppBar, champs et bouton', (tester) async {
    await pumpLogin(tester, UserRepository(service: service));

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Activités'),
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'Login'), findsOneWidget);
    final password = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Password'),
    );
    expect(password.obscureText, isTrue);
  });

  testWidgets('champs vides : reste sur le login', (tester) async {
    await pumpLogin(tester, UserRepository(service: service));
    await submit(tester);

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(HomeView), findsNothing);
    expect(
      find.text('Renseignez votre login et votre mot de passe.'),
      findsOneWidget,
    );
  });

  testWidgets('mauvais identifiants : reste sur le login', (tester) async {
    await pumpLogin(tester, UserRepository(service: service));
    await submit(tester, login: 'alice', password: 'faux');

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(HomeView), findsNothing);
    expect(find.text('Login ou mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('saisie après une erreur : le message disparaît', (tester) async {
    await pumpLogin(tester, UserRepository(service: service));
    await submit(tester, login: 'alice', password: 'faux');
    await tester.enterText(find.widgetWithText(TextField, 'Login'), 'alic');
    await tester.pumpAndSettle();

    expect(find.text('Login ou mot de passe incorrect.'), findsNothing);
  });

  testWidgets('bouton œil : affiche puis masque le mot de passe', (
    tester,
  ) async {
    await pumpLogin(tester, UserRepository(service: service));
    TextField password() =>
        tester.widget<TextField>(find.widgetWithText(TextField, 'Password'));

    await tester.tap(find.byTooltip('Afficher le mot de passe'));
    await tester.pump();
    expect(password().obscureText, isFalse);

    await tester.tap(find.byTooltip('Masquer le mot de passe'));
    await tester.pump();
    expect(password().obscureText, isTrue);
  });

  testWidgets('erreur du repository : reste sur le login sans crash', (
    tester,
  ) async {
    await pumpLogin(tester, _FailingUserRepository(service));
    await submit(tester, login: 'alice', password: 'alice123');

    expect(tester.takeException(), isNull);
    expect(find.byType(LoginView), findsOneWidget);
    expect(
      find.text('Connexion impossible. Vérifiez votre réseau et réessayez.'),
      findsOneWidget,
    );
  });

  testWidgets('bons identifiants : affiche la page suivante', (tester) async {
    await pumpLogin(tester, UserRepository(service: service));
    await submit(tester, login: 'alice', password: 'alice123');

    expect(find.byType(LoginView), findsNothing);
    expect(tester.widget<HomeView>(find.byType(HomeView)).userId, 'u1');
  });
}
