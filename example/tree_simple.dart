// Port of lipgloss/examples/tree/simple/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/tree.dart';

void main() {
  final t = Tree.root('Ratatouille')
    ..child('Tomatoes')
    ..child('Eggplant')
    ..child('Zucchini')
    ..child('Red Peppers')
    ..child('Yellow Squash');

  t.enumerator(roundedEnumerator);
  t.indenter(roundedIndenter);

  print(t.render());
}
