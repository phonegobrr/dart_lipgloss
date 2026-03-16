import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_lipgloss/tree.dart';

void main() {
  group('Tree', () {
    test('renders root only', () {
      final t = Tree.root('Root');
      expect(t.render(), equals('Root'));
    });

    test('renders with children', () {
      final t = Tree.root('Root')
        ..child('Child 1')
        ..child('Child 2');
      final result = t.render();
      expect(result, contains('Root'));
      expect(result, contains('Child 1'));
      expect(result, contains('Child 2'));
      expect(result, contains('├'));
      expect(result, contains('└'));
    });

    test('renders nested trees', () {
      final t = Tree.root('Root')
        ..child(Tree.root('Branch')
          ..child('Leaf 1')
          ..child('Leaf 2'))
        ..child('Other');
      final result = t.render();
      expect(result, contains('Root'));
      expect(result, contains('Branch'));
      expect(result, contains('Leaf 1'));
      expect(result, contains('Other'));
    });

    test('rounded enumerator', () {
      final t = Tree.root('Root')
        ..child('A')
        ..child('B');
      t.enumerator(roundedEnumerator);
      final result = t.render();
      expect(result, contains('╰'));
    });

    test('toString equals render', () {
      final t = Tree.root('Test')..child('X');
      expect(t.toString(), equals(t.render()));
    });
  });

  group('TreeLeaf', () {
    test('toString returns value', () {
      expect(TreeLeaf('hello').toString(), equals('hello'));
    });
  });

  group('Tree golden tests', () {
    test('basic tree matches golden', () {
      final t = Tree.root('Root')
        ..child('Alpha')
        ..child('Beta')
        ..child('Gamma');
      final expected =
          File('test/testdata/tree/basic.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });

    test('rounded tree matches golden', () {
      final t = Tree.root('Root')
        ..child('Alpha')
        ..child('Beta')
        ..child('Gamma');
      t.enumerator(roundedEnumerator);
      t.indenter(roundedIndenter);
      final expected =
          File('test/testdata/tree/rounded.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });

    test('nested tree matches golden', () {
      final t = Tree.root('Root')
        ..child(Tree.root('Branch A')
          ..child('Leaf 1')
          ..child('Leaf 2'))
        ..child(Tree.root('Branch B')..child('Leaf 3'))
        ..child('Leaf C');
      final expected =
          File('test/testdata/tree/nested.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });
  });
}
