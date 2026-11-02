import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Autenticação com Firebase Auth (e-mail e senha).
/// A senha fica só no Firebase Auth, guardada com hash no servidor.
/// Os dados de perfil ficam no Firestore, em `users/{uid}`.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  /// Avisa sempre que o usuário entra ou sai (inclusive ao abrir o app).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return getProfile(cred.user!);
  }

  Future<UserModel> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);

    final user = UserModel(
      uid: cred.user!.uid,
      name: name,
      email: email,
      phone: phone,
    );

    await _users.doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  /// Busca o perfil no Firestore. Se ainda não existir, monta com os
  /// dados básicos do Firebase Auth.
  Future<UserModel> getProfile(User fbUser) async {
    final doc = await _users.doc(fbUser.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(fbUser.uid, doc.data()!);
    }
    return UserModel(
      uid: fbUser.uid,
      name: fbUser.displayName ?? '',
      email: fbUser.email ?? '',
    );
  }

  Future<void> updateProfile(UserModel user) async {
    await _users.doc(user.uid).set(
      {'name': user.name, 'phone': user.phone},
      SetOptions(merge: true),
    );
    await _auth.currentUser?.updateDisplayName(user.name);
  }

  /// O Firebase exige login recente para trocar a senha,
  /// por isso o usuário confirma a senha atual antes.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() => _auth.signOut();
}
