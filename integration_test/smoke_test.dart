import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:natura/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('smoke test flow', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    app.main();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(); // without second call it hangs at the beginnig
    expect(find.text('What NaturaTest Offers'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton)); // proceed (to address search)
    await tester.pumpAndSettle();
    // await tester.tap(find.byType(TextField));
    // await tester.pumpAndSettle();
    // await tester.enterText(find.byType(TextField), '669 Pilgrim Dr., Foster City, CA, 94404');
    // await tester.pumpAndSettle();
    // push "skip (address search)"
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close)); // close settings screen
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow)); // start interview
    await tester.pumpAndSettle();
    //expect(find.text('Listen to the questions and speak the answers\n to pass the test.'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
