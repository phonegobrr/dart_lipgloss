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
  });
}
