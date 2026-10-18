class ScoreResult {
  const ScoreResult(this.total, this.maximum, this.message);
  final double total;
  final double maximum;
  final String message;
  double get percentage => maximum == 0 ? 0 : total / maximum * 100;
}

double value(double? input) => input == null || !input.isFinite ? 0 : input;

ScoreResult theoryScore(List<double?> marks) {
  final total =
      value(marks.elementAtOrNull(0)) / 50 * 8 +
      value(marks.elementAtOrNull(1)) / 50 * 8 +
      value(marks.elementAtOrNull(2)) / 10 * 4 +
      value(marks.elementAtOrNull(3)) / 10 * 4 +
      value(marks.elementAtOrNull(4)) / 10 * 6 +
      value(marks.elementAtOrNull(5)) / 100 * 10;
  final result = total.clamp(0, 40).toDouble();
  return ScoreResult(
    result,
    40,
    result >= 35
        ? 'Excellent work!'
        : result >= 30
        ? 'Great job!'
        : result >= 20
        ? 'Good effort, keep improving.'
        : 'Needs improvement.',
  );
}

ScoreResult integratedScore(List<double?> marks) {
  final total =
      value(marks.elementAtOrNull(0)) / 50 * 7 +
      value(marks.elementAtOrNull(1)) / 50 * 7 +
      value(marks.elementAtOrNull(2)) / 100 * 11 +
      value(marks.elementAtOrNull(3)) / 50 * 7 +
      value(marks.elementAtOrNull(4)) / 50 * 7 +
      value(marks.elementAtOrNull(5)) / 100 * 11;
  final result = total.clamp(0, 50).toDouble();
  return ScoreResult(
    result,
    50,
    result >= 45
        ? 'Outstanding performance!'
        : result >= 35
        ? 'Great job!'
        : result >= 25
        ? 'Good effort.'
        : 'Focus on the practicals.',
  );
}

double requiredMark(
  double target,
  double known,
  double weight,
  double maximum,
) => (target - known) / weight * maximum;

double gradePoint(double finalMark) => finalMark >= 90
    ? 10
    : finalMark >= 80
    ? 9
    : finalMark >= 70
    ? 8
    : finalMark >= 60
    ? 7
    : finalMark >= 50
    ? 6
    : finalMark >= 40
    ? 5
    : 0;

double weightedAverage(List<(double value, double weight)> values) {
  final weight = values.fold<double>(0, (sum, item) => sum + item.$2);
  return weight == 0
      ? (values.isEmpty
            ? 0
            : values.map((e) => e.$1).reduce((a, b) => a + b) / values.length)
      : values.fold<double>(0, (sum, item) => sum + item.$1 * item.$2) / weight;
}
