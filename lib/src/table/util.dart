// Ported from charmbracelet/lipgloss/table
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Bool to int.
int btoi(bool b) => b ? 1 : 0;

/// Sum of a list of ints.
int sum(List<int> values) => values.fold(0, (a, b) => a + b);

/// Median of a list of ints.
double median(List<int> values) {
  if (values.isEmpty) return 0;
  final sorted = List<int>.from(values)..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[mid].toDouble();
  return (sorted[mid - 1] + sorted[mid]) / 2.0;
}
