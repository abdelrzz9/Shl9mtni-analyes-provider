import 'package:flutter_test/flutter_test.dart';

import 'package:math_app/main.dart';

void main() {
  testWidgets('MathApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MathApp());
    expect(find.byType(MathApp), findsOneWidget);
  });
}
