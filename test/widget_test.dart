import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sqlite/main.dart'; // Agar sizning ilova nomi bu bo‘lsa

void main() {
  testWidgets('Notes App - Add note test', (WidgetTester tester) async {
    // Ilovani ishga tushiring
    await tester.pumpWidget(MaterialApp(home: NotesPage()));

    // Dastlab hech qanday eslatma bo‘lmasligi mumkin (yangi baza)
    expect(find.byType(ListTile), findsNothing);

    // "+" tugmasini topib bosing
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Modal form ochilganini tekshiramiz
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);

    // Matn kiritamiz
    await tester.enterText(find.byType(TextField).at(0), 'Test Note');
    await tester.enterText(find.byType(TextField).at(1), 'This is a test');

    // Saqlash tugmasini bosing
    await tester.tap(find.text('Add Note'));
    await tester.pumpAndSettle();

    // Endi ListTile mavjud bo'lishi kerak
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Test Note'), findsOneWidget);
    expect(find.text('This is a test'), findsOneWidget);
  });
}
