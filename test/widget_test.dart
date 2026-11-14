
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_leiloes/main.dart';

void main() {
  testWidgets('Portal de Leilões exibe a tela inicial', (tester) async {
    await tester.pumpWidget(const LeilaoApp());

    expect(find.text('Portal de Leilões'), findsOneWidget);
    expect(find.text('Explore os leilões'), findsOneWidget);
    expect(find.text('Notebook corporativo'), findsOneWidget);
    expect(find.byIcon(Icons.gavel), findsWidgets);
  });
}
