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
}
