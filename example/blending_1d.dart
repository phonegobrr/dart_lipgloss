// Port of lipgloss/examples/blending/linear-1d/standalone/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  final stops = [
    lipColor('#FF6B6B'),
    lipColor('#FFE66D'),
    lipColor('#4ECDC4'),
    lipColor('#7D56F4'),
  ];

  final gradient = blend1D(60, stops);
  final buf = StringBuffer();
  for (final c in gradient) {
    buf.write(Style().background(c).render(' '));
  }
  print('1D CIELAB Gradient:');
  print(buf);
  print('');

  // Reverse
  final reversed = blend1D(60, stops.reversed.toList());
  final buf2 = StringBuffer();
  for (final c in reversed) {
    buf2.write(Style().background(c).render(' '));
  }
  print('Reversed:');
  print(buf2);
}
