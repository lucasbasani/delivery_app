/// Funções de formatação usadas nas telas.

String formatPrice(double price) {
  return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
}

String formatDateTime(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}

/// "42999990000" -> "(42) 99999-0000"
String formatPhone(String digits) {
  if (digits.length == 11) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
  }
  if (digits.length == 10) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
  }
  return digits;
}

/// "84000000" -> "84000-000"
String formatCep(String digits) {
  if (digits.length != 8) return digits;
  return '${digits.substring(0, 5)}-${digits.substring(5)}';
}

/// Converte o texto digitado ("50,00" ou "50.00") em número.
double? parseMoney(String? text) {
  if (text == null || text.trim().isEmpty) return null;
  return double.tryParse(text.trim().replaceAll(',', '.'));
}
