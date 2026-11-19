/// Validações reutilizáveis dos formulários.
abstract final class Validators {
  static final RegExp _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');
  static final RegExp _digit = RegExp(r'\d');

  /// Detecta e-mail ou sequência longa de dígitos (telefone/documento).
  static bool containsPersonalData(String text) =>
      _email.hasMatch(text) || _digit.allMatches(text).length >= 8;

  static String? category(String? value) => value == null ? 'Selecione uma categoria.' : null;

  static String? description(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Descreva o que está acontecendo.';
    if (text.length < 10) return 'Use pelo menos 10 caracteres.';
    if (text.length > 280) return 'Use no máximo 280 caracteres.';
    if (containsPersonalData(text)) return 'Remova e-mails, telefones ou outros dados pessoais.';
    return null;
  }

  static String? location(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe o local (rua, praça ou bairro).';
    if (text.length < 3) return 'Use pelo menos 3 caracteres.';
    if (text.length > 60) return 'Use no máximo 60 caracteres.';
    if (_email.hasMatch(text)) return 'Não informe e-mail neste campo.';
    return null;
  }

  static double? parseNumber(String? value) =>
      value == null ? null : double.tryParse(value.trim().replaceAll(',', '.'));

  static String? numberInRange(String? value, {required double min, required double max, required String unit}) {
    if (value == null || value.trim().isEmpty) return 'Informe um valor.';
    final n = parseNumber(value);
    if (n == null) return 'Digite um número válido.';
    if (n < min || n > max) {
      return 'Use um valor entre ${min.toStringAsFixed(0)} e ${max.toStringAsFixed(0)} $unit.';
    }
    return null;
  }
}
