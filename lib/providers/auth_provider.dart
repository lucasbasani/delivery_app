import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  bool get isAuthenticated => _user != null;

  Future<bool> login(
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.login(
      email,
      password,
    );

    _user = user;

    _isLoading = false;
    notifyListeners();

    return user != null;
  }

  Future<String?> register(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    if (_authService.emailExists(email)) {
      _isLoading = false;
      notifyListeners();

      return 'Este e-mail já está cadastrado.';
    }

    _user = await _authService.register(
      name,
      email,
      password,
    );

    _isLoading = false;
    notifyListeners();

    return null;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}