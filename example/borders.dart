// Border showcase for dart_lipgloss.
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  final borders = <String, Border>{
    'Normal': normalBorder,
    'Rounded': roundedBorder,
    'Thick': thickBorder,
    'Double': doubleBorder,
    'Block': blockBorder,
    'Outer Half': outerHalfBlockBorder,
    'Inner Half': innerHalfBlockBorder,
    'Hidden': hiddenBorder,
    'ASCII': asciiBorder,
  };

  for (final entry in borders.entries) {
    print(Style()
        .border(entry.value)
        .borderForeground(lipColor('#7D56F4'))
        .padding(0, 2)
        .render(entry.key));
    print('');
  }
}
