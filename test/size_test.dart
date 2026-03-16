import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('size functions', () {
    test('getWidth single line', () {
      expect(getWidth('hello'), equals(5));
    });

    test('getWidth multi-line returns widest', () {
      expect(getWidth('hi\nhello\nhi'), equals(5));
    });

    test('getWidth empty string', () {
      expect(getWidth(''), equals(0));
    });

    test('getHeight single line', () {
      expect(getHeight('hello'), equals(1));
    });

    test('getHeight multi-line', () {
      expect(getHeight('a\nb\nc'), equals(3));
    });

    test('getHeight empty string', () {
      expect(getHeight(''), equals(0));
    });

    test('getSize returns both', () {
      final (w, h) = getSize('hello\nworld');
      expect(w, equals(5));
      expect(h, equals(2));
    });
  });
}
