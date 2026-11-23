import 'package:flutter_test/flutter_test.dart';
import 'package:jarti/app/app.dart';
import 'package:jarti/core/storage/local_store.dart';
import 'package:jarti/state/app_state.dart';

void main() {
  testWidgets('signed-out users see the phone login screen', (tester) async {
    final state = AppState(store: LocalStore.memory());
    // bootstrap uses real delays, so run it outside the fake test clock.
    await tester.runAsync(state.bootstrap);

    await tester.pumpWidget(JartiApp(state: state));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('أرسل رمز التحقق'), findsOneWidget);
    expect(find.text('مواطن / عميل'), findsOneWidget);
  });
}
