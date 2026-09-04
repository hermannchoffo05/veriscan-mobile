import 'package:flutter_test/flutter_test.dart';
import 'package:veriscan_mobile/main.dart';

void main() {
  testWidgets('VeriScan smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VeriScanApp());
  });
}