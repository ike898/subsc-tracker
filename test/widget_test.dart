import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsc_tracker/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SubscTrackerApp()),
    );
    expect(find.text('SubscTracker'), findsOneWidget);
  });
}
