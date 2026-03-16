// Port of lipgloss/examples/table/languages/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/table.dart';

void main() {
  final t = Table()
    ..headers(['LANGUAGE', 'FORMAL', 'INFORMAL'])
    ..rows([
      ['Chinese', 'Nǐn hǎo', 'Nǐ hǎo'],
      ['French', 'Bonjour', 'Salut'],
      ['Japanese', 'こんにちは', 'やあ'],
      ['Russian', 'Zdravstvuyte', 'Privet'],
      ['Spanish', 'Hola', '¿Qué tal?'],
    ])
    ..borderDef(roundedBorder)
    ..borderColumn(true)
    ..borderStyleDef(Style().foreground(lipColor('#874BFD')))
    ..styleFunc((row, col) {
      if (row == headerRow) {
        return Style().bold().foreground(lipColor('#FAFAFA'));
      }
      return const Style();
    });

  print(t.render());
}
