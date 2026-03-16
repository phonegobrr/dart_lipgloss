// Port of lipgloss/examples/blending/linear-2d/standalone/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  const width = 40;
  const height = 12;

  final stops = [
    lipColor('#FF6B6B'),
    lipColor('#4ECDC4'),
    lipColor('#7D56F4'),
    lipColor('#FFE66D'),
  ];

  // 2D gradient at 45 degrees
  final gradient = blend2D(width, height, 45.0, stops);

  print('2D CIELAB Gradient (45°):');
  for (var y = 0; y < height; y++) {
    final buf = StringBuffer();
    for (var x = 0; x < width; x++) {
      final color = gradient[y * width + x];
      buf.write(Style().background(color).render(' '));
    }
    print(buf);
  }

  print('');

  // Horizontal gradient (0 degrees)
  final horizontal = blend2D(width, height, 0.0, stops);
  print('2D CIELAB Gradient (0° horizontal):');
  for (var y = 0; y < height; y++) {
    final buf = StringBuffer();
    for (var x = 0; x < width; x++) {
      final color = horizontal[y * width + x];
      buf.write(Style().background(color).render(' '));
    }
    print(buf);
  }
}
