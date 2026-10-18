import 'package:flutter_test/flutter_test.dart';
import 'package:markify_flutter/calculations.dart';
import 'package:markify_flutter/main.dart';

void main() {
  test('calculates maximum theory and integrated scores', () {
    expect(theoryScore([50, 50, 10, 10, 10, 100]).total, 40);
    expect(integratedScore([50, 50, 100, 50, 50, 100]).total, 50);
  });

  test('uses score threshold messages', () {
    expect(theoryScore([50, 50, 10, 10, 10, 100]).message, 'Excellent work!');
    expect(integratedScore([0, 0, 0, 0, 0, 0]).message, 'Focus on the practicals.');
  });

  test('calculates grade points and weighted averages', () {
    expect(gradePoint(90), 10);
    expect(gradePoint(80), 9);
    expect(gradePoint(40), 5);
    expect(weightedAverage([(10, 3), (8, 1)]), 9.5);
    expect(weightedAverage([(7, 0), (9, 0)]), 8);
  });

  testWidgets('opens Markify home screen', (tester) async {
    await tester.pumpWidget(const MarkifyApp());
    expect(find.text('All your academic calculations in one place'), findsOneWidget);
    expect(find.text('Internal Score'), findsOneWidget);
  });
}
