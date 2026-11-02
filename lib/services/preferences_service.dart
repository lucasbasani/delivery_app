import 'package:shared_preferences/shared_preferences.dart';

/// Dados locais do aparelho (SharedPreferences):
/// o e-mail lembrado no login e a última forma de pagamento usada.
class PreferencesService {
  static const _kEmail = 'saved_email';
  static const _kPayment = 'last_payment_method';

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail);
  }

  /// Passe `null` para esquecer o e-mail.
  Future<void> setSavedEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_kEmail);
    } else {
      await prefs.setString(_kEmail, email);
    }
  }

  Future<String?> getLastPaymentMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPayment);
  }

  Future<void> setLastPaymentMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPayment, method);
  }
}
