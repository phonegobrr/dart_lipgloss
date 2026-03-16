// Color showcase for dart_lipgloss.
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  // ANSI 16 colors
  print('ANSI 16 colors:');
  final buf = StringBuffer();
  for (var i = 0; i < 16; i++) {
    buf.write(Style().background(ANSIColor(i)).render('  '));
  }
  print(buf);

  // ANSI 256 colors
  print('\nANSI 256 color cube:');
  for (var row = 0; row < 6; row++) {
    final rowBuf = StringBuffer();
    for (var col = 0; col < 36; col++) {
      final idx = 16 + row * 36 + col;
      rowBuf.write(Style().background(ANSI256Color(idx)).render(' '));
    }
    print(rowBuf);
  }

  // TrueColor hex examples
  print('\nTrueColor hex:');
  final hexColors = [
    '#FF6B6B',
    '#FF8E53',
    '#FFE66D',
    '#4ECDC4',
    '#45B7D1',
    '#7D56F4',
    '#FF6B9D',
    '#C7F464',
  ];
  final hexBuf = StringBuffer();
  for (final hex in hexColors) {
    hexBuf.write(Style()
        .background(lipColor(hex))
        .foreground(lipColor('#FFFFFF'))
        .padding(0, 1)
        .render(hex));
    hexBuf.write(' ');
  }
  print(hexBuf);

  // Color utilities
  print('\nDarken / Lighten:');
  final base = lipColor('#7D56F4');
  final darkened = darken(base, 0.3);
  final lightened = lighten(base, 0.3);
  print(Style().background(darkened).padding(0, 2).render('Darkened'));
  print(Style().background(base).padding(0, 2).render('Base'));
  print(Style().background(lightened).padding(0, 2).render('Lightened'));
}
