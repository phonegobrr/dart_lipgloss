// Port of lipgloss/examples/tree/files/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/tree.dart';

void main() {
  final t = Tree.root('dart_lipgloss')
    ..child(Tree.root('lib')
      ..child(Tree.root('src')
        ..child('style.dart')
        ..child('color.dart')
        ..child('border.dart')))
    ..child(Tree.root('test')
      ..child('style_test.dart')
      ..child('color_test.dart'))
    ..child('pubspec.yaml')
    ..child('README.md');

  t
    ..enumerator(roundedEnumerator)
    ..indenter(roundedIndenter)
    ..enumeratorStyle(Style().foreground(lipColor('#4ECDC4')))
    ..rootStyle(Style().bold().foreground(lipColor('#7D56F4')));

  print(t.render());
}
