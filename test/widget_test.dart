import 'package:flutter_test/flutter_test.dart';
import 'package:pawme/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PawMeApp());
    expect(find.byType(PawMeApp), findsOneWidget);
  });
}