import 'package:flutter_test/flutter_test.dart';
import 'package:cybershield_app/main.dart';

void main() {
  testWidgets('CyberShield app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CyberShieldApp());
    expect(find.byType(CyberShieldApp), findsOneWidget);
  });
}
