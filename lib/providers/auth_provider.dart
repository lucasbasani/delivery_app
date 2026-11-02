import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _subscription;

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitializing = true;

  // Enquanto login/cadastro rodam, quem define o usuário é o próprio
  // método, e não o listener (evita sobrescrever com dados incompletos).
  bool _ignoreAuthEvents = false;

  AuthProvider(this._authService) {
    // Mantém a sessão: ao abrir o app, o Firebase informa se já há login.
    _subscription = _authService.authStateChanges.listen(_onAuthChanged);
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _user != null;

  Future<void> _onAuthChanged(User? fbUser) async {
    if (_ignoreAuthEvents) return;

    if (fbUser == null) {
      _user = null;
    } else {
      try {
        _user = await _authService.getProfile(fbUser);
      } catch (_) {
        _user = UserModel(
          uid: fbUser.uid,
          name: fbUser.displayName ?? '',
          email: fbUser.email ?? '',
        );
      }
    }
    _isInitializing = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) {
    return _run(() async {
      _user = await _authService.login(email, password);
    });
  }

  Future<String?> register(
    String name,
    String email,
    String phone,
    String password,
  ) {
    return _run(() async {
      _user = await _authService.register(name, email, phone, password);
    });
  }

  Future<String?> updateProfile(String name, String phone) {
    return _run(() async {
      final updated = _user!.copyWith(name: name, phone: phone);
      await _authService.updateProfile(updated);
      _user = updated;
    });
  }

  Future<String?> changePassword(String current, String newPassword) {
    return _run(
      () => _authService.changePassword(current, newPassword),
      invalidCredentialMessage: 'A senha atual está incorreta.',
    );
  }

  Future<String?> resetPassword(String email) {
    return _run(() => _authService.sendPasswordReset(email));
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  /// Executa uma ação do Firebase controlando o loading.
  /// Retorna `null` em caso de sucesso ou a mensagem de erro em português.
  Future<String?> _run(
    Future<void> Function() action, {
    String? invalidCredentialMessage,
  }) async {
    _isLoading = true;
    _ignoreAuthEvents = true;
    notifyListeners();

    try {
      await action();
      return null;
    } on FirebaseAuthException catch (e) {
      return _translate(e.code, invalidCredentialMessage);
    } on FirebaseException catch (_) {
      return 'Erro ao acessar o banco de dados. Tente novamente.';
    } catch (_) {
      return 'Erro inesperado. Tente novamente.';
    } finally {
      _isLoading = false;
      _ignoreAuthEvents = false;
      _isInitializing = false;
      notifyListeners();
    }
  }

  String _translate(String code, String? invalidCredentialMessage) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return invalidCredentialMessage ?? 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'requires-recent-login':
        return 'Por segurança, saia e entre novamente.';
      default:
        return 'Erro de autenticação ($code).';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
