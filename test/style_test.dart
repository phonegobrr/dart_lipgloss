import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('Style', () {
    test('immutable - builder returns new instance', () {
      final s1 = Style();
      final s2 = s1.bold();
      expect(identical(s1, s2), isFalse);
      expect(s2.getBold, isTrue);
      expect(s1.getBold, isFalse);
    });

    test('render plain text passes through', () {
      expect(Style().render('hello'), equals('hello'));
    });

    test('render with bold wraps in ANSI', () {
      final result = Style().bold().render('hello');
      expect(result, contains('\x1b['));
      expect(result, contains('1m'));
      expect(result, contains('hello'));
      expect(result, endsWith('\x1b[0m'));
    });

    test('render with foreground color', () {
      final result = Style().foreground(lipColor('#FF0000')).render('red');
      expect(result, contains('\x1b['));
      expect(result, contains('red'));
      expect(result, endsWith('\x1b[0m'));
    });

    test('render with background color', () {
      final result = Style().background(lipColor('#00FF00')).render('green');
      expect(result, contains('\x1b['));
      expect(result, contains('green'));
    });

    test('padding adds spaces', () {
      final result = Style().padding(1).render('x');
      expect(result, contains('x'));
      // Should have extra lines/spaces
      final lines = result.split('\n');
      expect(lines.length, greaterThan(1));
    });

    test('CSS shorthand padding - 1 arg', () {
      final s = Style().padding(2);
      expect(s.getPaddingTop, equals(2));
      expect(s.getPaddingRight, equals(2));
      expect(s.getPaddingBottom, equals(2));
      expect(s.getPaddingLeft, equals(2));
    });

    test('CSS shorthand padding - 2 args', () {
      final s = Style().padding(1, 3);
      expect(s.getPaddingTop, equals(1));
      expect(s.getPaddingRight, equals(3));
      expect(s.getPaddingBottom, equals(1));
      expect(s.getPaddingLeft, equals(3));
    });

    test('CSS shorthand padding - 4 args', () {
      final s = Style().padding(1, 2, 3, 4);
      expect(s.getPaddingTop, equals(1));
      expect(s.getPaddingRight, equals(2));
      expect(s.getPaddingBottom, equals(3));
      expect(s.getPaddingLeft, equals(4));
    });

    test('width constrains output', () {
      final result = Style().width(10).render('hello');
      final lines = result.split('\n');
      for (final line in lines) {
        expect(stringWidth(line), lessThanOrEqualTo(10));
      }
    });

    test('border adds border characters', () {
      final result = Style().border(roundedBorder).render('test');
      expect(result, contains('╭'));
      expect(result, contains('╯'));
      expect(result, contains('test'));
    });

    test('maxWidth truncates', () {
      final result = Style().maxWidth(5).render('hello world');
      final maxW = result
          .split('\n')
          .map(stringWidth)
          .reduce((a, b) => a > b ? a : b);
      expect(maxW, lessThanOrEqualTo(5));
    });

    test('maxHeight truncates lines', () {
      final result = Style().maxHeight(2).render('line1\nline2\nline3\nline4');
      expect(result.split('\n').length, equals(2));
    });

    test('horizontal frame size', () {
      final s = Style()
          .paddingLeft(2)
          .paddingRight(3)
          .border(normalBorder);
      expect(s.getHorizontalFrameSize, equals(2 + 3 + 1 + 1)); // padding + borders
    });

    test('vertical frame size', () {
      final s = Style()
          .paddingTop(1)
          .paddingBottom(2)
          .border(normalBorder);
      expect(s.getVerticalFrameSize, equals(1 + 2 + 1 + 1)); // padding + borders
    });

    test('setString sets value', () {
      final s = Style().bold().setString('prefix: ');
      expect(s.render('content'), contains('prefix: '));
      expect(s.render('content'), contains('content'));
    });

    test('unset removes property', () {
      final s = Style().bold().unsetBold();
      expect(s.getBold, isFalse);
    });

    test('inherit copies unset properties', () {
      final parent = Style().bold().foreground(lipColor('#FF0000'));
      final child = Style().italic().inherit(parent);
      expect(child.getBold, isTrue);
      expect(child.getItalic, isTrue);
    });

    test('inherit does not override set properties', () {
      final parent = Style().bold();
      final child = Style().bold(false).inherit(parent);
      expect(child.getBold, isFalse);
    });

    test('inline mode strips newlines', () {
      final result = Style().inlineMode().render('line1\nline2');
      expect(result, isNot(contains('\n')));
    });

    test('tab conversion', () {
      final result = Style().render('\thello');
      expect(result, contains('    hello'));
    });

    test('tab conversion with custom width', () {
      final result = Style().tabWidth(2).render('\thello');
      expect(result, contains('  hello'));
    });

    test('margin adds space', () {
      final result = Style().marginLeft(2).render('x');
      expect(result, startsWith('  '));
    });

    test('transform function applied', () {
      final result = Style()
          .transform((s) => s.toUpperCase())
          .render('hello');
      expect(result, equals('HELLO'));
    });

    test('align center', () {
      final result = Style().width(20).align(posCenter).render('hi');
      expect(stringWidth(result.split('\n').first), equals(20));
    });

    test('toString returns rendered value for setString', () {
      final s = Style().bold().setString('hello');
      expect(s.toString(), isNotEmpty);
      expect(s.toString(), contains('hello'));
    });

    test('toString returns empty for no value', () {
      expect(Style().toString(), equals(''));
    });
  });
}
