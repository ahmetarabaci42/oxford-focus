import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxford_focus/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: OxfordFocusApp(),
      ),
    );

    // Verify that our title is present.
    expect(find.text('Oxford Focus'), findsOneWidget);
  });
}
