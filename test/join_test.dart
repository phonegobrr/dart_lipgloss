import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('joinHorizontal', () {
    test('joins two blocks side by side', () {
      final result = joinHorizontal(posTop, ['AB\nCD', 'EF\nGH']);
      final lines = result.split('\n');
      expect(lines.length, equals(2));
      expect(lines[0], contains('AB'));
      expect(lines[0], contains('EF'));
      expect(lines[1], contains('CD'));
      expect(lines[1], contains('GH'));
    });

    test('pads shorter blocks', () {
      final result = joinHorizontal(posTop, ['A\nB\nC', 'X']);
      final lines = result.split('\n');
      expect(lines.length, equals(3));
    });

    test('empty list returns empty', () {
      expect(joinHorizontal(posTop, []), equals(''));
    });

    test('single item returns itself', () {
      expect(joinHorizontal(posTop, ['hello']), equals('hello'));
    });

    test('bottom alignment', () {
      final result = joinHorizontal(posBottom, ['A', 'X\nY\nZ']);
      final lines = result.split('\n');
      expect(lines.length, equals(3));
      // A should be at the bottom
      expect(lines.last, contains('A'));
    });
  });

  group('joinVertical', () {
    test('stacks blocks vertically', () {
      final result = joinVertical(posLeft, ['Hello', 'World']);
      final lines = result.split('\n');
      expect(lines.length, equals(2));
      expect(lines[0], contains('Hello'));
      expect(lines[1], contains('World'));
    });

    test('aligns to max width', () {
      final result = joinVertical(posLeft, ['Hi', 'Hello']);
      final lines = result.split('\n');
      // Both lines should be padded to same width
      expect(stringWidth(lines[0]), equals(stringWidth(lines[1])));
    });

    test('center alignment', () {
      final result = joinVertical(posCenter, ['Hi', 'Hello']);
      final lines = result.split('\n');
      expect(stringWidth(lines[0]), equals(stringWidth(lines[1])));
    });

    test('empty list returns empty', () {
      expect(joinVertical(posLeft, []), equals(''));
    });
  });
}
