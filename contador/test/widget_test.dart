// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:contador/main.dart';

void main() {
  testWidgets('Finance dashboard loads and shows banking features', (WidgetTester tester) async {
    await Hive.initFlutter();
    await FinanceStorage.init();
    await tester.pumpWidget(const MyApp());

    expect(find.text('Controle financeiro'), findsOneWidget);
    expect(find.text('Saldo total'), findsOneWidget);
    expect(find.text('Principal'), findsOneWidget);
    expect(find.text('Mês atual'), findsOneWidget);
    expect(find.text('Recorrentes'), findsOneWidget);
    expect(find.text('Receita'), findsOneWidget);
    expect(find.text('Despesa'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });
}
