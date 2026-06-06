import 'package:flutter_test/flutter_test.dart';
import 'package:animal_lover/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimalLoverApp());
    expect(find.byType(AnimalLoverApp), findsOneWidget);
  });
}
