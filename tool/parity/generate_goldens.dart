import 'dart:io';
import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/table.dart';
import 'package:dart_lipgloss/tree.dart';
import 'package:dart_lipgloss/list.dart';

void main() {
  // Table golden files
  _write('test/testdata/table/basic.golden', () {
    final t = Table()
      ..headers(['NAME', 'VALUE'])
      ..rows([['Alpha', '1'], ['Beta', '2'], ['Gamma', '3']])
      ..borderDef(normalBorder)
      ..borderColumn(true);
    return t.render();
  });

  _write('test/testdata/table/rounded.golden', () {
    final t = Table()
      ..headers(['NAME', 'VALUE'])
      ..rows([['Alpha', '1'], ['Beta', '2'], ['Gamma', '3']])
      ..borderDef(roundedBorder)
      ..borderColumn(true);
    return t.render();
  });

  _write('test/testdata/table/no_border.golden', () {
    final t = Table()
      ..headers(['NAME', 'VALUE'])
      ..rows([['Alpha', '1'], ['Beta', '2']])
      ..borderDef(noBorder)
      ..borderEdges(top: false, bottom: false, left: false, right: false)
      ..borderHeader(false);
    return t.render();
  });

  _write('test/testdata/table/columns.golden', () {
    final t = Table()
      ..headers(['A', 'B', 'C'])
      ..rows([['1', '2', '3'], ['4', '5', '6']])
      ..borderDef(normalBorder)
      ..borderColumn(true);
    return t.render();
  });

  // Tree golden files
  _write('test/testdata/tree/basic.golden', () {
    final t = Tree.root('Root')
      ..child('Alpha')
      ..child('Beta')
      ..child('Gamma');
    return t.render();
  });

  _write('test/testdata/tree/rounded.golden', () {
    final t = Tree.root('Root')
      ..child('Alpha')
      ..child('Beta')
      ..child('Gamma');
    t.enumerator(roundedEnumerator);
    t.indenter(roundedIndenter);
    return t.render();
  });

  _write('test/testdata/tree/nested.golden', () {
    final t = Tree.root('Root')
      ..child(Tree.root('Branch A')..child('Leaf 1')..child('Leaf 2'))
      ..child(Tree.root('Branch B')..child('Leaf 3'))
      ..child('Leaf C');
    return t.render();
  });

  // List golden files
  _write('test/testdata/list/bullet.golden', () {
    final l = LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(bullet);
    return l.render();
  });

  _write('test/testdata/list/arabic.golden', () {
    final l = LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(arabic);
    return l.render();
  });

  _write('test/testdata/list/roman.golden', () {
    final l = LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(roman);
    return l.render();
  });

  print('All golden files generated.');
}

void _write(String path, String Function() renderer) {
  final content = renderer();
  File(path).writeAsStringSync(content);
  print('  wrote $path (${content.length} bytes)');
}
