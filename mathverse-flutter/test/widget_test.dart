import 'package:flutter_test/flutter_test.dart';

import 'package:mathverse_flutter/main.dart';
import 'package:mathverse_flutter/di/injection_container.dart' as di;

void main() {
  setUpAll(() async {
    await di.initDependencies();
  });

  testWidgets('MathApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MathApp());
    expect(find.byType(MathApp), findsOneWidget);
  });
}
