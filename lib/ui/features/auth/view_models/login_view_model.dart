import 'package:flutter/foundation.dart';

import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/models/app_user.dart';

enum LoginError { missingFields, invalidCredentials, unavailable }

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._userRepository});

  final UserRepository _userRepository;

  AppUser? _user;
  bool _isLoading = false;
  LoginError? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  LoginError? get error => _error;

  /// Renvoie true si l'utilisateur est authentifié. Les échecs (identifiants
  /// inconnus ou erreur du repository) sont loggés et exposés via [error] ;
  /// aucune exception n'est levée.
  Future<bool> login(String login, String password) async {
    if (_isLoading) return false;
    if (login.isEmpty || password.isEmpty) {
      _error = LoginError.missingFields;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _userRepository.login(login, password);
      if (_user == null) {
        debugPrint('Login échoué : utilisateur inconnu');
        _error = LoginError.invalidCredentials;
      }
    } catch (e) {
      _user = null;
      _error = LoginError.unavailable;
      debugPrint('Login impossible : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _user != null;
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
