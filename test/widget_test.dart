import 'package:flutter_test/flutter_test.dart';
import 'package:my_expense/main.dart'; // Ensure this matches your project name

void main() {
  testWidgets('Liveness screen load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyExpenseApp());

    // Verify that the Liveness Screen is the first thing the user sees.
    // Based on your liveness_screen.dart
    expect(find.text('Liveness Check'), findsOneWidget);

    // Verify the initial status message is present.
    expect(find.text('Initializing Camera...'), findsOneWidget);
  });
}
