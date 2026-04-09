import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diamond_clean/features/auth/presentation/screens/login_screen.dart';
import 'package:diamond_clean/firebase_options.dart';
import 'package:diamond_clean/main.dart';

void main() {
  testWidgets('app shows the login screen when unauthenticated', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

    await tester.pumpWidget(const DiamondCleanApp());
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
