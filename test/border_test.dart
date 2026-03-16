import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('Border', () {
    test('normalBorder has all characters', () {
      expect(normalBorder.top, isNotEmpty);
      expect(normalBorder.bottom, isNotEmpty);
      expect(normalBorder.left, isNotEmpty);
      expect(normalBorder.right, isNotEmpty);
      expect(normalBorder.topLeft, isNotEmpty);
      expect(normalBorder.topRight, isNotEmpty);
      expect(normalBorder.bottomLeft, isNotEmpty);
      expect(normalBorder.bottomRight, isNotEmpty);
    });

    test('roundedBorder has rounded corners', () {
      expect(roundedBorder.topLeft, equals('╭'));
      expect(roundedBorder.topRight, equals('╮'));
      expect(roundedBorder.bottomLeft, equals('╰'));
      expect(roundedBorder.bottomRight, equals('╯'));
    });

    test('hiddenBorder has space characters', () {
      expect(hiddenBorder.top, equals(' '));
      expect(hiddenBorder.left, equals(' '));
    });

    test('noBorder has empty strings', () {
      expect(noBorder.top, isEmpty);
      expect(noBorder.left, isEmpty);
    });

    test('getTopSize', () {
      expect(normalBorder.getTopSize(), equals(1));
      expect(noBorder.getTopSize(), equals(0));
    });

    test('getBottomSize', () {
      expect(normalBorder.getBottomSize(), equals(1));
      expect(noBorder.getBottomSize(), equals(0));
    });

    test('getLeftSize', () {
      expect(normalBorder.getLeftSize(), equals(1));
      expect(noBorder.getLeftSize(), equals(0));
    });

    test('getRightSize', () {
      expect(normalBorder.getRightSize(), equals(1));
      expect(noBorder.getRightSize(), equals(0));
    });

    test('equality', () {
      expect(normalBorder, equals(normalBorder));
      expect(normalBorder, isNot(equals(roundedBorder)));
    });

    test('renderHorizontalEdge', () {
      final edge = renderHorizontalEdge('┌', '─', '┐', 10);
      expect(edge, startsWith('┌'));
      expect(edge, endsWith('┐'));
      expect(stringWidth(edge), equals(10));
    });
  });

  group('Style with border', () {
    test('render with normalBorder', () {
      final result = Style().border(normalBorder).render('hi');
      expect(result, contains('┌'));
      expect(result, contains('└'));
      expect(result, contains('│'));
      expect(result, contains('hi'));
    });

    test('render with roundedBorder', () {
      final result = Style().border(roundedBorder).render('test');
      expect(result, contains('╭'));
      expect(result, contains('╯'));
    });

    test('render with only top and bottom borders', () {
      final result =
          Style().border(normalBorder, true, false, true, false).render('x');
      expect(result, contains('─'));
      expect(result, isNot(contains('│')));
    });

    test('border with colored foreground', () {
      final result = Style()
          .border(normalBorder)
          .borderForeground(lipColor('#FF0000'))
          .render('test');
      expect(result, contains('\x1b['));
    });
  });
}
