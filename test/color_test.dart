import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('Color', () {
    test('parse hex with hash', () {
      final c = lipColor('#FF0000');
      expect(c, isA<RGBColor>());
      final rgba = c.rgba;
      expect(rgba.r, equals(255));
      expect(rgba.g, equals(0));
      expect(rgba.b, equals(0));
    });

    test('parse hex without hash', () {
      final c = lipColor('00FF00');
      expect(c, isA<RGBColor>());
      expect(c.rgba.g, equals(255));
    });

    test('parse short hex', () {
      final c = lipColor('#F0F');
      expect(c, isA<RGBColor>());
      expect(c.rgba.r, equals(255));
      expect(c.rgba.g, equals(0));
      expect(c.rgba.b, equals(255));
    });

    test('parse ANSI index', () {
      final c = lipColor('5');
      expect(c, isA<ANSIColor>());
      expect((c as ANSIColor).value, equals(5));
    });

    test('parse ANSI 256 index', () {
      final c = lipColor('200');
      expect(c, isA<ANSI256Color>());
      expect((c as ANSI256Color).value, equals(200));
    });

    test('parse empty string returns NoColor', () {
      expect(lipColor(''), isA<NoColor>());
    });

    test('NoColor rgba', () {
      final c = const NoColor();
      expect(c.rgba.r, equals(0));
      expect(c.rgba.a, equals(0));
    });

    test('ANSIColor rgba', () {
      final c = const ANSIColor(1); // Red
      expect(c.rgba.r, greaterThan(0));
    });

    test('ANSI256Color grayscale', () {
      final c = const ANSI256Color(240);
      final rgba = c.rgba;
      expect(rgba.r, equals(rgba.g));
      expect(rgba.g, equals(rgba.b));
    });

    test('ANSI256Color cube', () {
      final c = const ANSI256Color(196); // Bright red in cube
      expect(c.rgba.r, greaterThan(0));
    });

    test('isDarkColor', () {
      expect(isDarkColor(lipColor('#000000')), isTrue);
      expect(isDarkColor(lipColor('#FFFFFF')), isFalse);
      expect(isDarkColor(lipColor('#333333')), isTrue);
      expect(isDarkColor(lipColor('#CCCCCC')), isFalse);
    });

    test('complementary', () {
      final c = complementary(lipColor('#FF0000'));
      final rgba = c.rgba;
      expect(rgba.r, equals(0));
      expect(rgba.g, equals(255));
      expect(rgba.b, equals(255));
    });

    test('darken', () {
      final base = lipColor('#FF8800');
      final dark = darken(base, 0.5);
      expect(dark.rgba.r, lessThan(base.rgba.r));
    });

    test('lighten', () {
      final base = lipColor('#004488');
      final light = lighten(base, 0.5);
      expect(light.rgba.r, greaterThan(base.rgba.r));
    });

    test('rgbToAnsi256', () {
      final result = rgbToAnsi256(const RGBColor(255, 0, 0));
      expect(result.value, greaterThanOrEqualTo(16));
      expect(result.value, lessThanOrEqualTo(231));
    });

    test('rgbToAnsi256 grayscale', () {
      final result = rgbToAnsi256(const RGBColor(128, 128, 128));
      expect(result.value, greaterThanOrEqualTo(232));
    });

    test('rgbToAnsi16', () {
      final result = rgbToAnsi16(const RGBColor(255, 0, 0));
      expect(result.value, greaterThanOrEqualTo(0));
      expect(result.value, lessThanOrEqualTo(15));
    });

    test('named color constants', () {
      expect(lipglossBlack.value, equals(0));
      expect(lipglossRed.value, equals(1));
      expect(lipglossBrightWhite.value, equals(15));
    });

    test('equality', () {
      expect(lipColor('#FF0000'), equals(lipColor('#FF0000')));
      expect(const ANSIColor(5), equals(const ANSIColor(5)));
      expect(const ANSI256Color(200), equals(const ANSI256Color(200)));
      expect(const NoColor(), equals(const NoColor()));
    });
  });
}
