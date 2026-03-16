import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('alignTextHorizontal', () {
    test('left alignment', () {
      final result = alignTextHorizontal('hi', 0.0, 10);
      expect(result, startsWith('hi'));
      expect(stringWidth(result), equals(10));
    });

    test('right alignment', () {
      final result = alignTextHorizontal('hi', 1.0, 10);
      expect(result, endsWith('hi'));
      expect(stringWidth(result), equals(10));
    });

    test('center alignment', () {
      final result = alignTextHorizontal('hi', 0.5, 10);
      expect(stringWidth(result), equals(10));
      // Should have padding on both sides
      expect(result, isNot(startsWith('hi')));
      expect(result, isNot(endsWith('hi')));
    });

    test('text wider than width unchanged', () {
      final result = alignTextHorizontal('hello world', 0.5, 5);
      expect(result, equals('hello world'));
    });
  });

  group('alignTextVertical', () {
    test('top alignment', () {
      final result = alignTextVertical('hi', 0.0, 3);
      final lines = result.split('\n');
      expect(lines.length, equals(3));
      expect(lines[0], equals('hi'));
    });

    test('bottom alignment', () {
      final result = alignTextVertical('hi', 1.0, 3);
      final lines = result.split('\n');
      expect(lines.length, equals(3));
      expect(lines.last, equals('hi'));
    });

    test('text taller than height unchanged', () {
      final result = alignTextVertical('a\nb\nc', 0.5, 2);
      expect(result, equals('a\nb\nc'));
    });
  });
}
