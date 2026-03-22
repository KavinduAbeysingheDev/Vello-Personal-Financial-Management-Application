import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Savings Goals screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Savings Goals screen is displayed.
    expect(find.text('Savings Goals'), findsOneWidget);
    expect(find.byIcon(Icons.eco), findsOneWidget);
  });
}