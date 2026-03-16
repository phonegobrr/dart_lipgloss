import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('blend1D', () {
    test('single stop repeats', () {
      final result = blend1D(5, [lipColor('#FF0000')]);
      expect(result.length, equals(5));
      for (final c in result) {
        expect(c.rgba.r, equals(255));
      }
    });

    test('two stops creates gradient', () {
      final result = blend1D(5, [lipColor('#000000'), lipColor('#FFFFFF')]);
      expect(result.length, equals(5));
      // First should be black
      expect(result.first.rgba.r, equals(0));
      // Last should be white
      expect(result.last.rgba.r, equals(255));
      // Middle should be between
      expect(result[2].rgba.r, greaterThan(0));
      expect(result[2].rgba.r, lessThan(255));
    });

    test('empty stops returns empty', () {
      expect(blend1D(5, []), isEmpty);
    });

    test('zero steps returns empty', () {
      expect(blend1D(0, [lipColor('#FF0000')]), isEmpty);
    });

    test('multiple stops', () {
      final result = blend1D(
        10,
        [lipColor('#FF0000'), lipColor('#00FF00'), lipColor('#0000FF')],
      );
      expect(result.length, equals(10));
    });
  });

  group('blend2D', () {
    test('creates grid', () {
      final result = blend2D(
        5,
        3,
        0,
        [lipColor('#FF0000'), lipColor('#0000FF')],
      );
      expect(result.length, equals(15)); // 5 * 3
    });

    test('empty inputs', () {
      expect(blend2D(0, 0, 0, []), isEmpty);
    });
  });
}
