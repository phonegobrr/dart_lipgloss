import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('wordWrap', () {
    test('no wrap needed', () {
      expect(wordWrap('hello', 10), equals('hello'));
    });

    test('wraps at word boundary', () {
      final result = wordWrap('hello world', 7);
      expect(result, contains('\n'));
      for (final line in result.split('\n')) {
        expect(stringWidth(line), lessThanOrEqualTo(7));
      }
    });

    test('preserves existing newlines', () {
      final result = wordWrap('hi\nthere', 20);
      expect(result, equals('hi\nthere'));
    });

    test('zero limit returns original', () {
      expect(wordWrap('hello', 0), equals('hello'));
    });
  });

  group('hardWrap', () {
    test('no wrap needed', () {
      expect(hardWrap('hello', 10), equals('hello'));
    });

    test('wraps mid-word', () {
      final result = hardWrap('helloworld', 5);
      expect(result, contains('\n'));
      for (final line in result.split('\n')) {
        expect(stringWidth(line), lessThanOrEqualTo(5));
      }
    });
  });
}
