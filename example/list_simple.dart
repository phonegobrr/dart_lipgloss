// Port of lipgloss/examples/list/simple/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/list.dart';

void main() {
  final list = LipglossList([
    'Tomatoes',
    'Peppers',
    'Onions',
    'Garlic',
    'Basil',
  ])
    ..enumerator(bullet)
    ..enumeratorStyle(Style().foreground(lipColor('#FF6B6B')));

  print(list.render());
}
