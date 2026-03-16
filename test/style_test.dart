import 'dart:io';

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
      final maxW =
          result.split('\n').map(stringWidth).reduce((a, b) => a > b ? a : b);
      expect(maxW, lessThanOrEqualTo(5));
    });

    test('maxHeight truncates lines', () {
      final result = Style().maxHeight(2).render('line1\nline2\nline3\nline4');
      expect(result.split('\n').length, equals(2));
    });

    test('horizontal frame size', () {
      final s = Style().paddingLeft(2).paddingRight(3).border(normalBorder);
      expect(
          s.getHorizontalFrameSize, equals(2 + 3 + 1 + 1)); // padding + borders
    });

    test('vertical frame size', () {
      final s = Style().paddingTop(1).paddingBottom(2).border(normalBorder);
      expect(
          s.getVerticalFrameSize, equals(1 + 2 + 1 + 1)); // padding + borders
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
      final result = Style().inline().render('line1\nline2');
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
      final result = Style().transform((s) => s.toUpperCase()).render('hello');
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

  // ─── Parity behavioral tests ───

  group('Style.Inherit parity', () {
    test('inherits formatting but not padding', () {
      final parent = Style().bold().padding(2);
      final child = Style().inherit(parent);
      expect(child.getBold, isTrue);
      expect(child.getPaddingTop, equals(0));
      expect(child.getPaddingRight, equals(0));
      expect(child.getPaddingBottom, equals(0));
      expect(child.getPaddingLeft, equals(0));
    });

    test('inherits formatting but not margins', () {
      final parent = Style().italic().margin(3);
      final child = Style().inherit(parent);
      expect(child.getItalic, isTrue);
      expect(child.getMarginTop, equals(0));
    });

    test('propagates background to marginBackground', () {
      final parent = Style().background(lipColor('#FF0000'));
      final child = Style().inherit(parent);
      expect(child.getBackground, isA<RGBColor>());
      expect(child.getMarginBackground, isA<RGBColor>());
    });

    test('does not override explicit marginBackground', () {
      final parent = Style().background(lipColor('#FF0000'));
      final child =
          Style().marginBackground(lipColor('#00FF00')).inherit(parent);
      final rgba = child.getMarginBackground.rgba;
      expect(rgba.g, equals(255)); // green, not red
    });
  });

  group('Inline parity', () {
    test('inline skips padding, borders, margins', () {
      final s = Style()
          .inline()
          .padding(1)
          .border(normalBorder)
          .marginLeft(2);
      final result = s.render('hello\nworld');
      expect(result, isNot(contains('\n')));
      expect(result, isNot(contains('┌')));
      expect(result, isNot(contains('│')));
    });
  });

  group('TabWidth parity', () {
    test('tabWidth(0) removes tabs', () {
      final result = Style().tabWidth(0).render('hello\tworld');
      expect(result, equals('helloworld'));
    });

    test('tabWidth(-1) preserves tabs', () {
      final result = Style().tabWidth(noTabConversion).render('a\tb');
      expect(result, contains('\t'));
    });
  });

  group('Height vs MaxHeight parity', () {
    test('height is minimum, does not crop', () {
      final result = Style().height(2).render('line1\nline2\nline3\nline4');
      expect(result.split('\n').length, equals(4)); // all 4 lines preserved
    });

    test('height pads short content', () {
      final result = Style().height(5).render('line1\nline2');
      expect(result.split('\n').length, equals(5));
    });

    test('maxHeight crops', () {
      final result = Style().maxHeight(2).render('line1\nline2\nline3');
      expect(result.split('\n').length, equals(2));
    });
  });

  group('SetString + Render parity', () {
    test('setString prepends to render', () {
      final s = Style().setString('hello');
      final result = s.render('world');
      expect(result, equals('hello world'));
    });

    test('setString variadic joins with spaces', () {
      final s = Style().setString('hello', ['beautiful', 'world']);
      expect(s.render(), equals('hello beautiful world'));
    });

    test('render with list joins with spaces', () {
      final s = Style().setString('prefix');
      final result = s.render(['a', 'b']);
      expect(result, equals('prefix a b'));
    });

    test('unsetString clears value', () {
      final s = Style().setString('hello').unsetString();
      expect(s.getValue, isNull);
    });
  });

  group('Border shorthand/defaults parity', () {
    test('borderStyle alone auto-enables all sides', () {
      final s = Style().borderStyle(roundedBorder);
      expect(s.getBorderTopSize, equals(1));
      expect(s.getBorderBottomSize, equals(1));
      expect(s.getBorderLeftSize, greaterThan(0));
      expect(s.getBorderRightSize, greaterThan(0));
    });

    test('border(style, true) enables all sides', () {
      final s = Style().border(normalBorder, true);
      expect(s.getBorderTop, isTrue);
      expect(s.getBorderRight, isTrue);
      expect(s.getBorderBottom, isTrue);
      expect(s.getBorderLeft, isTrue);
    });

    test('border(style, true, false) = vert only', () {
      final s = Style().border(normalBorder, true, false);
      expect(s.getBorderTop, isTrue);
      expect(s.getBorderRight, isFalse);
      expect(s.getBorderBottom, isTrue);
      expect(s.getBorderLeft, isFalse);
    });

    test('empty corners filled with space', () {
      final result = Style()
          .border(Border(top: '─', bottom: '─', left: '│', right: '│'), true)
          .render('x');
      // Corners should be spaces, not empty
      expect(result, contains(' '));
    });
  });

  group('Width/alignment parity', () {
    test('width without explicit align left-aligns by default', () {
      final result = Style().width(20).render('short');
      expect(stringWidth(result.split('\n').first), equals(20));
    });

    test('width + center alignment', () {
      final result = Style().width(20).align(posCenter).render('hi');
      final line = result.split('\n').first;
      expect(stringWidth(line), equals(20));
      // 'hi' is 2 chars, so left padding = 9
      expect(line, startsWith('         '));
    });

    test('align(horizontal) does not set vertical', () {
      final s = Style().align(posCenter);
      expect(s.getAlignHorizontal, equals(0.5));
      expect(s.getAlignVertical, equals(0.0));
    });

    test('align(horizontal, vertical) sets both', () {
      final s = Style().align(posCenter, posBottom);
      expect(s.getAlignHorizontal, equals(0.5));
      expect(s.getAlignVertical, equals(1.0));
    });
  });

  // ─── Golden file tests ───

  group('Style golden tests', () {
    test('inline', () {
      final expected =
          File('test/testdata/style/inline.golden').readAsStringSync();
      expect(Style().inline().render('hello\nworld'), equals(expected));
    });

    test('tabwidth zero', () {
      final expected =
          File('test/testdata/style/tabwidth_zero.golden').readAsStringSync();
      expect(Style().tabWidth(0).render('hello\tworld'), equals(expected));
    });

    test('height minimum', () {
      final expected =
          File('test/testdata/style/height_minimum.golden').readAsStringSync();
      expect(Style().height(5).render('line1\nline2'), equals(expected));
    });

    test('height does not crop', () {
      final expected =
          File('test/testdata/style/height_no_crop.golden').readAsStringSync();
      expect(Style().height(2).render('line1\nline2\nline3\nline4'),
          equals(expected));
    });

    test('maxHeight crops', () {
      final expected =
          File('test/testdata/style/maxheight_crop.golden').readAsStringSync();
      expect(Style().maxHeight(2).render('line1\nline2\nline3\nline4'),
          equals(expected));
    });

    test('border auto sides', () {
      final expected = File('test/testdata/style/border_auto_sides.golden')
          .readAsStringSync();
      expect(
          Style().borderStyle(roundedBorder).render('hello'), equals(expected));
    });

    test('setstring render', () {
      final expected = File('test/testdata/style/setstring_render.golden')
          .readAsStringSync();
      expect(Style().setString('hello').render('world'), equals(expected));
    });

    test('setstring variadic', () {
      final expected = File('test/testdata/style/setstring_variadic.golden')
          .readAsStringSync();
      expect(Style().setString('hello', ['beautiful', 'world']).render(),
          equals(expected));
    });

    test('inherit no padding', () {
      final expected = File('test/testdata/style/inherit_no_padding.golden')
          .readAsStringSync();
      final parent = Style().padding(2);
      final child = Style().inherit(parent);
      final result = '${child.getPaddingTop}:${child.getPaddingRight}:'
          '${child.getPaddingBottom}:${child.getPaddingLeft}';
      expect(result, equals(expected));
    });

    test('inline skips layout', () {
      final expected = File('test/testdata/style/inline_skips_layout.golden')
          .readAsStringSync();
      final s = Style()
          .inline()
          .padding(1)
          .border(normalBorder)
          .marginLeft(2);
      expect(s.render('hello\nworld'), equals(expected));
    });

    test('width alignment default', () {
      final expected =
          File('test/testdata/style/width_alignment_default.golden')
              .readAsStringSync();
      expect(Style().width(20).render('short'), equals(expected));
    });

    test('width alignment center', () {
      final expected =
          File('test/testdata/style/width_alignment_center.golden')
              .readAsStringSync();
      expect(
          Style().width(20).align(posCenter).render('short'), equals(expected));
    });

    test('width alignment right', () {
      final expected = File('test/testdata/style/width_alignment_right.golden')
          .readAsStringSync();
      expect(
          Style().width(20).align(posRight).render('short'), equals(expected));
    });
  });
}
