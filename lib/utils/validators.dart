/// Validações reutilizadas por todos os formulários do app.
/// Cada método segue a assinatura esperada pelo `validator` do TextFormField:
/// retorna a mensagem de erro ou `null` quando o valor é válido.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  /// Remove tudo que não for dígito (ex.: "(42) 99999-0000" -> "42999990000").
  static String onlyDigits(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  static String? requiredField(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite seu nome';
    }
    if (value.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 letras';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value.trim())) {
      return 'Use apenas letras e espaços';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite seu e-mail';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  /// Senha forte: 6+ caracteres, uma maiúscula e um número.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite uma senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha precisa ter uma letra maiúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha precisa ter um número';
    }
    return null;
  }

  /// Telefone com DDD: 10 (fixo) ou 11 (celular) dígitos.
  static String? phone(String? value) {
    final digits = onlyDigits(value ?? '');
    if (digits.isEmpty) {
      return 'Informe o telefone';
    }
    if (digits.length < 10 || digits.length > 11) {
      return 'Telefone com DDD (10 ou 11 dígitos)';
    }
    return null;
  }

  static String? cep(String? value) {
    final digits = onlyDigits(value ?? '');
    if (digits.isEmpty) {
      return 'Informe o CEP';
    }
    if (digits.length != 8) {
      return 'O CEP deve ter 8 dígitos';
    }
    return null;
  }

  /// Número do endereço: só dígitos (ex.: 410) ou "S/N".
  static String? houseNumber(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) {
      return 'Informe o número';
    }
    if (v != 'S/N' && !RegExp(r'^[0-9]+[A-Z]?$').hasMatch(v)) {
      return 'Número inválido (use S/N se não houver)';
    }
    return null;
  }

  static String? uf(String? value) {
    if (value == null || !ufs.contains(value)) {
      return 'Selecione o estado';
    }
    return null;
  }

  static const ufs = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];
}
