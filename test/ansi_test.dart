import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('stripAnsi', () {
    test('strips SGR', () {
      expect(stripAnsi('\x1b[31mred\x1b[0m'), equals('red'));
    });

    test('strips multiple SGR', () {
      expect(
        stripAnsi('\x1b[1m\x1b[31mbold red\x1b[0m'),
        equals('bold red'),
      );
    });

    test('strips OSC hyperlink', () {
      expect(
        stripAnsi('\x1b]8;;https://example.com\x1b\\link\x1b]8;;\x1b\\'),
        equals('link'),
      );
    });

    test('no-op on plain text', () {
      expect(stripAnsi('hello world'), equals('hello world'));
    });

    test('empty string', () {
      expect(stripAnsi(''), equals(''));
    });
  });

  group('stringWidth', () {
    test('ASCII', () {
      expect(stringWidth('hello'), equals(5));
    });

    test('empty string', () {
      expect(stringWidth(''), equals(0));
    });

    test('with ANSI escapes', () {
      expect(stringWidth('\x1b[1mhello\x1b[0m'), equals(5));
    });

    test('CJK double-width', () {
      expect(stringWidth('你好'), equals(4));
    });

    test('mixed ASCII and CJK', () {
      expect(stringWidth('hi你'), equals(4));
    });

    test('spaces', () {
      expect(stringWidth('   '), equals(3));
    });

    test('newline not counted in single line', () {
      // stringWidth works on single lines
      expect(stringWidth('hello'), equals(5));
    });
  });

  group('runeWidth', () {
    test('ASCII character', () {
      expect(runeWidth('A'.codeUnitAt(0)), equals(1));
    });

    test('CJK ideograph', () {
      expect(runeWidth('你'.runes.first), equals(2));
    });

    test('null character is zero width', () {
      expect(runeWidth(0), equals(0));
    });

    test('combining mark is zero width', () {
      expect(runeWidth(0x0300), equals(0));
    });
  });

  group('truncate', () {
    test('no truncation needed', () {
      expect(truncate('hello', 10), equals('hello'));
    });

    test('truncates to width', () {
      final result = truncate('hello world', 5);
      expect(stringWidth(result), lessThanOrEqualTo(5));
    });

    test('truncates with tail', () {
      final result = truncate('hello world', 8, '...');
      expect(stringWidth(result), lessThanOrEqualTo(8));
      expect(result, endsWith('...'));
    });

    test('zero width returns empty', () {
      expect(truncate('hello', 0), equals(''));
    });
  });

  group('hyperlink', () {
    test('creates OSC 8 hyperlink', () {
      final result = hyperlink('https://example.com', 'click');
      expect(result, contains('\x1b]8;'));
      expect(result, contains('https://example.com'));
      expect(result, contains('click'));
    });
  });

  group('AnsiStyle', () {
    test('styled wraps text', () {
      final s = AnsiStyle()..setBold();
      final result = s.styled('test');
      expect(result, startsWith('\x1b['));
      expect(result, contains('1m'));
      expect(result, contains('test'));
      expect(result, endsWith('\x1b[0m'));
    });

    test('empty style returns original', () {
      final s = AnsiStyle();
      expect(s.styled('test'), equals('test'));
    });

    test('foreground color', () {
      final s = AnsiStyle()..setForeground(const RGBColor(255, 0, 0));
      final result = s.styled('red');
      expect(result, contains('38;2;255;0;0'));
    });

    test('background color', () {
      final s = AnsiStyle()..setBackground(const ANSIColor(4));
      final result = s.styled('blue');
      expect(result, contains('44'));
    });
  });
}
