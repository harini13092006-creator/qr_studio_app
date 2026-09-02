import 'package:flutter_test/flutter_test.dart';
import 'package:qr_studio_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('QR Studio app renders its home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const QRStudioApp());
    await tester.pump();

    expect(find.text('QR Studio'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
