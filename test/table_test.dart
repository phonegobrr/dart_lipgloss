import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/table.dart';

void main() {
  group('Table', () {
    test('renders basic table', () {
      final t = Table()
        ..headers(['A', 'B'])
        ..rows([
          ['1', '2'],
          ['3', '4'],
        ]);
      final result = t.render();
      expect(result, contains('A'));
      expect(result, contains('B'));
      expect(result, contains('1'));
      expect(result, contains('4'));
    });

    test('renders with rounded border', () {
      final t = Table()
        ..headers(['X'])
        ..row(['Y'])
        ..borderDef(roundedBorder);
      final result = t.render();
      expect(result, contains('╭'));
      expect(result, contains('╰'));
    });

    test('renders with column borders', () {
      final t = Table()
        ..headers(['A', 'B'])
        ..row(['1', '2'])
        ..borderDef(normalBorder)
        ..borderColumn(true);
      final result = t.render();
      expect(result, contains('│'));
    });

    test('renders with style function', () {
      final t = Table()
        ..headers(['Name'])
        ..row(['Test'])
        ..borderDef(normalBorder)
        ..styleFunc((row, col) {
          if (row == headerRow) {
            return Style().bold();
          }
          return const Style();
        });
      final result = t.render();
      expect(result, contains('Name'));
      expect(result, contains('Test'));
    });

    test('empty table returns empty string', () {
      final t = Table();
      expect(t.render(), isEmpty);
    });

    test('toString equals render', () {
      final t = Table()
        ..headers(['X'])
        ..row(['Y']);
      expect(t.toString(), equals(t.render()));
    });
  });

  group('Data interfaces', () {
    test('StringData basic', () {
      final d = StringData([
        ['a', 'b'],
        ['c', 'd'],
      ]);
      expect(d.rows, equals(2));
      expect(d.columns, equals(2));
      expect(d.at(0, 0), equals('a'));
      expect(d.at(1, 1), equals('d'));
    });

    test('StringData out of bounds', () {
      final d = StringData([
        ['a'],
      ]);
      expect(d.at(5, 0), equals(''));
      expect(d.at(0, 5), equals(''));
    });

    test('Filter', () {
      final d = StringData([
        ['a'],
        ['b'],
        ['c'],
      ]);
      final f = Filter(d, [0, 2]);
      expect(f.rows, equals(2));
      expect(f.at(0, 0), equals('a'));
      expect(f.at(1, 0), equals('c'));
    });
  });

  group('Table golden tests', () {
    test('basic table matches golden', () {
      final t = Table()
        ..headers(['NAME', 'VALUE'])
        ..rows([
          ['Alpha', '1'],
          ['Beta', '2'],
          ['Gamma', '3'],
        ])
        ..borderDef(normalBorder)
        ..borderColumn(true);
      final expected =
          File('test/testdata/table/basic.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });

    test('rounded table matches golden', () {
      final t = Table()
        ..headers(['NAME', 'VALUE'])
        ..rows([
          ['Alpha', '1'],
          ['Beta', '2'],
          ['Gamma', '3'],
        ])
        ..borderDef(roundedBorder)
        ..borderColumn(true);
      final expected =
          File('test/testdata/table/rounded.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });

    test('columns table matches golden', () {
      final t = Table()
        ..headers(['A', 'B', 'C'])
        ..rows([
          ['1', '2', '3'],
          ['4', '5', '6'],
        ])
        ..borderDef(normalBorder)
        ..borderColumn(true);
      final expected =
          File('test/testdata/table/columns.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });

    test('no_border table matches golden', () {
      final t = Table()
        ..headers(['NAME', 'VALUE'])
        ..rows([
          ['Alpha', '1'],
          ['Beta', '2'],
        ])
        ..borderDef(noBorder)
        ..borderEdges(top: false, bottom: false, left: false, right: false)
        ..borderHeader(false);
      final expected =
          File('test/testdata/table/no_border.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });
  });
}
