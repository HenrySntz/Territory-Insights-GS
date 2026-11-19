import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:territory_insights/widgets/common.dart';

void main() {
  testWidgets('aviso de decisão humana é exibido', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DisclaimerBanner())));
    expect(find.textContaining('decisão humana'), findsOneWidget);
  });

  testWidgets('estado vazio mostra a mensagem', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: StateView.empty(message: 'Nada por aqui'))));
    expect(find.text('Nada por aqui'), findsOneWidget);
  });
}
