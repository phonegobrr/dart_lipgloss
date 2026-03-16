import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  group('Canvas', () {
    test('basic render fills empty cells with spaces', () {
      final c = Canvas(5, 2);
      final result = c.render();
      expect(result, equals('     \n     '));
    });

    test('compose places text at position', () {
      final c = Canvas(10, 1);
      c.compose(3, 0, 'hi');
      final result = c.render();
      expect(result, contains('hi'));
      expect(stringWidth(result), equals(10));
    });

    test('resize preserves content', () {
      final c = Canvas(5, 1);
      c.compose(0, 0, 'AB');
      c.resize(10, 2);
      expect(c.width, equals(10));
      expect(c.height, equals(2));
      final result = c.render();
      expect(result, contains('AB'));
    });

    test('clear removes all cells', () {
      final c = Canvas(3, 1);
      c.compose(0, 0, 'XYZ');
      c.clear();
      final result = c.render();
      expect(result, equals('   '));
    });
  });

  group('Compositor', () {
    test('renders layers in z-order', () {
      final c = Compositor();
      c.addLayer(Layer(content: 'Hello', x: 0, y: 0, z: 0));
      c.addLayer(Layer(content: 'World', x: 6, y: 0, z: 1));
      final result = c.render();
      expect(result, contains('Hello'));
      expect(result, contains('World'));
    });

    test('higher z overlaps lower z', () {
      final c = Compositor();
      c.addLayer(Layer(content: 'AAAA\nAAAA', x: 0, y: 0, z: 0));
      c.addLayer(Layer(content: 'BB', x: 1, y: 0, z: 1));
      final result = c.render();
      // BB should overlay positions 1-2 on row 0
      expect(result.split('\n').first, contains('BB'));
    });

    test('hit test finds topmost layer', () {
      final c = Compositor();
      c.addLayer(Layer(id: 'bg', content: 'xxxxx', x: 0, y: 0, z: 0));
      c.addLayer(Layer(id: 'fg', content: 'AB', x: 1, y: 0, z: 1));
      final hit = c.hit(1, 0);
      expect(hit, isNotNull);
      expect(hit!.layer.id, equals('fg'));
    });

    test('getLayer finds by id', () {
      final c = Compositor();
      c.addLayer(Layer(id: 'test', content: 'X', x: 0, y: 0));
      expect(c.getLayer('test'), isNotNull);
      expect(c.getLayer('missing'), isNull);
    });

    test('empty compositor returns empty', () {
      expect(Compositor().render(), equals(''));
    });

    test('preserves ANSI in content', () {
      final c = Compositor();
      final styled = Style().bold().render('hi');
      c.addLayer(Layer(content: styled, x: 0, y: 0, z: 0));
      final result = c.render();
      expect(result, contains('\x1b['));
    });
  });

  group('Layer', () {
    test('width and height calculated from content', () {
      final l = Layer(content: 'abc\ndef');
      expect(l.width, equals(3));
      expect(l.height, equals(2));
    });

    test('immutable setters return new instance', () {
      final l = Layer(x: 0, y: 0, z: 0);
      final l2 = l.setX(5);
      expect(l.x, equals(0));
      expect(l2.x, equals(5));
    });
  });

  // ─── Golden file tests ───

  group('Canvas golden tests', () {
    test('basic compositor matches golden', () {
      final c = Compositor();
      c.addLayer(Layer(content: 'Hello', x: 0, y: 0, z: 0));
      c.addLayer(Layer(content: 'World', x: 6, y: 0, z: 1));
      final expected =
          File('test/testdata/canvas/basic_compositor.golden')
              .readAsStringSync();
      expect(c.render(), equals(expected));
    });

    test('overlap matches golden', () {
      final c = Compositor();
      c.addLayer(Layer(content: 'AAAA\nAAAA', x: 0, y: 0, z: 0));
      c.addLayer(Layer(content: 'BB', x: 1, y: 0, z: 1));
      final expected =
          File('test/testdata/canvas/overlap.golden').readAsStringSync();
      expect(c.render(), equals(expected));
    });
  });
}
