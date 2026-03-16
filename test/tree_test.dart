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

  // ─── Parity behavioral tests ───

  group('Tree parity', () {
    test('hidden tree returns empty string', () {
      final t = Tree.root('Root')
        ..child('A')
        ..hide();
      expect(t.render(), equals(''));
    });

    test('hidden leaf is skipped', () {
      final t = Tree.root('Root')
        ..child('Visible')
        ..child(TreeLeaf('Hidden')..hide())
        ..child('Also Visible');
      final result = t.render();
      expect(result, contains('Visible'));
      expect(result, isNot(contains('Hidden')));
      expect(result, contains('Also Visible'));
    });

    test('offset skips first and last children', () {
      final t = Tree.root('Root')
        ..child('A')
        ..child('B')
        ..child('C')
        ..child('D')
        ..child('E');
      t.offset(1, 1);
      final result = t.render();
      expect(result, isNot(contains('A')));
      expect(result, contains('B'));
      expect(result, contains('C'));
      expect(result, contains('D'));
      expect(result, isNot(contains('E')));
    });

    test('width pads lines', () {
      final t = Tree.root('Root')
        ..child('Short')
        ..child('X');
      t.width(30);
      final result = t.render();
      final lines = result.split('\n');
      for (final line in lines) {
        expect(line.length, greaterThanOrEqualTo(10)); // padded
      }
    });

    test('multiline items render correctly', () {
      final t = Tree.root('Root')
        ..child('Line1\nLine2\nLine3')
        ..child('After');
      final result = t.render();
      expect(result, contains('Line1'));
      expect(result, contains('Line2'));
      expect(result, contains('Line3'));
      expect(result, contains('After'));
    });

    test('root mutation', () {
      final t = Tree.root('Original');
      t.root('Changed');
      expect(t.rootValue, equals('Changed'));
      expect(t.render(), contains('Changed'));
    });

    test('auto-nesting promotes leaf to subtree', () {
      final t = Tree.root('Root')
        ..child('Parent')
        ..child(Tree.root('')..child('Nested'));
      final result = t.render();
      expect(result, contains('Parent'));
      expect(result, contains('Nested'));
    });
  });

  // ─── Golden file tests ───

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

    test('hidden nodes match golden', () {
      final t = Tree.root('Root')
        ..child('Visible')
        ..child(TreeLeaf('Hidden')..hide())
        ..child('Also Visible');
      final expected =
          File('test/testdata/tree/hidden.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });

    test('offset match golden', () {
      final t = Tree.root('Root')
        ..child('A')
        ..child('B')
        ..child('C')
        ..child('D')
        ..child('E');
      t.offset(1, 1);
      final expected =
          File('test/testdata/tree/offset.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });

    test('width padding match golden', () {
      final t = Tree.root('Root')
        ..child('Short')
        ..child('X');
      t.width(30);
      final expected =
          File('test/testdata/tree/width_padding.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });

    test('multiline match golden', () {
      final t = Tree.root('Root')
        ..child('Line1\nLine2\nLine3')
        ..child('After');
      final expected =
          File('test/testdata/tree/multiline.golden').readAsStringSync();
      expect(t.render(), equals(expected));
    });
  });
}
