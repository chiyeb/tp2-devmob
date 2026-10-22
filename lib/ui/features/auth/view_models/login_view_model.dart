import 'package:flutter/foundation.dart';

import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/models/app_user.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._userRepository});

  final UserRepository _userRepository;

  AppUser? _user;
  bool _isLoading = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  /// Renvoie true si l'utilisateur est authentifié. Les échecs (identifiants
  /// inconnus ou erreur du repository) sont loggés et ne lèvent pas d'exception.
  Future<bool> login(String login, String password) async {
    if (_isLoading || login.isEmpty || password.isEmpty) return false;

    _isLoading = true;
    notifyListeners();
    try {
      _user = await _userRepository.login(login, password);
      if (_user == null) debugPrint('Login échoué : utilisateur inconnu');
    } catch (e) {
      _user = null;
      debugPrint('Login impossible : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _user != null;
  }
}
