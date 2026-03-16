// Port of lipgloss/examples/list/grocery/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/list.dart';

void main() {
  final produce = LipglossList(['Apples', 'Bananas', 'Oranges'])
    ..enumerator(arabic)
    ..enumeratorStyle(Style().foreground(lipColor('#4ECDC4')));

  final dairy = LipglossList(['Milk', 'Cheese', 'Butter'])
    ..enumerator(arabic)
    ..enumeratorStyle(Style().foreground(lipColor('#4ECDC4')));

  final bakery = LipglossList(['Bread', 'Croissants'])
    ..enumerator(arabic)
    ..enumeratorStyle(Style().foreground(lipColor('#4ECDC4')));

  // Top-level categories
  final grocery = LipglossList([
    'Produce:\n${produce.render()}',
    'Dairy:\n${dairy.render()}',
    'Bakery:\n${bakery.render()}',
  ])
    ..enumerator(bullet)
    ..enumeratorStyle(Style().foreground(lipColor('#FF6B6B')).bold());

  print(Style().bold().foreground(lipColor('#7D56F4')).render('Grocery List'));
  print('');
  print(grocery.render());
}
