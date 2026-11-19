import 'package:flutter_test/flutter_test.dart';
import 'package:territory_insights/core/validators.dart';

void main() {
  group('descrição', () {
    test('rejeita vazio, curto e dados pessoais', () {
      expect(Validators.description(''), isNotNull);
      expect(Validators.description('curto'), isNotNull);
      expect(Validators.description('Ligue para 11999998888 agora'), isNotNull);
      expect(Validators.description('Fale comigo: maria@email.com por favor'), isNotNull);
    });

    test('aceita descrição válida', () {
      expect(Validators.description('Vazamento na calçada há dois dias'), isNull);
    });
  });

  group('local', () {
    test('valida tamanho mínimo', () {
      expect(Validators.location('ab'), isNotNull);
      expect(Validators.location('Praça central'), isNull);
    });
  });

  group('número em faixa', () {
    test('valida formato e limites', () {
      expect(Validators.numberInRange('abc', min: 5, max: 100, unit: '%'), isNotNull);
      expect(Validators.numberInRange('3', min: 5, max: 100, unit: '%'), isNotNull);
      expect(Validators.numberInRange('15', min: 5, max: 100, unit: '%'), isNull);
      expect(Validators.numberInRange('32,5', min: 25, max: 45, unit: '°C'), isNull);
    });
  });
}
