import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_lipgloss/list.dart';

void main() {
  group('LipglossList', () {
    test('renders with bullet enumerator', () {
      final list = LipglossList(['Apple', 'Banana', 'Cherry'])
        ..enumerator(bullet);
      final result = list.render();
      expect(result, contains('•'));
      expect(result, contains('Apple'));
      expect(result, contains('Cherry'));
    });

    test('renders with arabic enumerator', () {
      final list = LipglossList(['A', 'B', 'C'])..enumerator(arabic);
      final result = list.render();
      expect(result, contains('1.'));
      expect(result, contains('2.'));
      expect(result, contains('3.'));
    });

    test('renders with roman enumerator', () {
      final list = LipglossList(['A', 'B', 'C'])..enumerator(roman);
      final result = list.render();
      expect(result, contains('I.'));
      expect(result, contains('II.'));
      expect(result, contains('III.'));
    });

    test('renders with dash enumerator', () {
      final list = LipglossList(['X'])..enumerator(dash);
      expect(list.render(), contains('- '));
    });

    test('renders with asterisk enumerator', () {
      final list = LipglossList(['X'])..enumerator(asterisk);
      expect(list.render(), contains('* '));
    });

    test('renders with alphabet enumerator', () {
      final list = LipglossList(['X', 'Y'])..enumerator(alphabet);
      final result = list.render();
      expect(result, contains('a.'));
      expect(result, contains('b.'));
    });

    test('empty list returns empty', () {
      expect(LipglossList([]).render(), isEmpty);
    });

    test('toString equals render', () {
      final list = LipglossList(['A', 'B']);
      expect(list.toString(), equals(list.render()));
    });
  });

  // ─── Parity behavioral tests ───

  group('List parity', () {
    test('roman numerals right-align', () {
      final items = List.generate(14, (i) => 'Item ${i + 1}');
      final result = (LipglossList(items)..enumerator(roman)).render();
      final lines = result.split('\n');
      // XIV. has 5 chars, I. has 3 chars - shorter ones get leading space padding
      // Verify shorter prefix is padded and longest is not
      expect(lines[0], startsWith('   I.')); // I. right-aligned
      expect(lines.last, contains('XIV.')); // longest, no padding
    });

    test('hidden list returns empty', () {
      final l = LipglossList(['A', 'B', 'C'])..hide();
      expect(l.render(), equals(''));
    });

    test('offset clips items', () {
      final l = LipglossList(['A', 'B', 'C', 'D', 'E'])..offset(1, 1);
      final result = l.render();
      expect(result, isNot(contains('A')));
      expect(result, contains('B'));
      expect(result, contains('C'));
      expect(result, contains('D'));
      expect(result, isNot(contains('E')));
    });

    test('item() and items() builders', () {
      final l = LipglossList([])
        ..item('First')
        ..items(['Second', 'Third']);
      final result = l.render();
      expect(result, contains('First'));
      expect(result, contains('Second'));
      expect(result, contains('Third'));
    });

    test('nested list renders sub-items', () {
      final inner = LipglossList(['Sub A', 'Sub B'])..enumerator(dash);
      final outer = LipglossList(['Top 1', inner, 'Top 2'])
        ..enumerator(bullet);
      final result = outer.render();
      expect(result, contains('Top 1'));
      expect(result, contains('Sub A'));
      expect(result, contains('Sub B'));
      expect(result, contains('Top 2'));
    });
  });

  // ─── Golden file tests ───

  group('List golden tests', () {
    test('bullet list matches golden', () {
      final l = LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(bullet);
      final expected =
          File('test/testdata/list/bullet.golden').readAsStringSync();
      expect(l.render(), equals(expected));
    });

    test('arabic list matches golden', () {
      final l = LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(arabic);
      final expected =
          File('test/testdata/list/arabic.golden').readAsStringSync();
      expect(l.render(), equals(expected));
    });

    test('roman list matches golden', () {
      final l = LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(roman);
      final expected =
          File('test/testdata/list/roman.golden').readAsStringSync();
      expect(l.render(), equals(expected));
    });

    test('roman alignment matches golden', () {
      final items = List.generate(14, (i) => 'Item ${i + 1}');
      final l = LipglossList(items)..enumerator(roman);
      final expected =
          File('test/testdata/list/roman_alignment.golden').readAsStringSync();
      expect(l.render(), equals(expected));
    });

    test('hidden list matches golden', () {
      final l = LipglossList(['A', 'B', 'C'])..hide();
      final expected =
          File('test/testdata/list/hidden.golden').readAsStringSync();
      expect(l.render(), equals(expected));
    });

    test('offset list matches golden', () {
      final l = LipglossList(['A', 'B', 'C', 'D', 'E'])..offset(1, 1);
      final expected =
          File('test/testdata/list/offset.golden').readAsStringSync();
      expect(l.render(), equals(expected));
    });

    test('nested list matches golden', () {
      final inner = LipglossList(['Sub A', 'Sub B'])..enumerator(dash);
      final outer = LipglossList(['Top 1', inner, 'Top 2'])
        ..enumerator(bullet);
      final expected =
          File('test/testdata/list/nested.golden').readAsStringSync();
      expect(outer.render(), equals(expected));
    });
  });
}
