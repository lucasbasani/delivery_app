import '../models/user_model.dart';

class AuthService {
  final List<UserModel> _users = [];

  Future<UserModel?> login(
    String email,
    String password,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (email == 'demo@email.com' && password == 'Demo@123') {
      return UserModel(
        name: 'Usuário Demo',
        email: email,
      );
    }

    for (final user in _users) {
      if (user.email == email) {
        return user;
      }
    }

    return null;
  }

  bool emailExists(String email) {
    return _users.any(
      (user) => user.email == email,
    );
  }

  Future<UserModel> register(
    String name,
    String email,
    String password,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final user = UserModel(
      name: name,
      email: email,
    );

    _users.add(user);

    return user;
  }
}