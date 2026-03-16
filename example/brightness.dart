// Lighten/darken color utility demo for dart_lipgloss.
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  final baseColors = [
    ('#FF6B6B', 'Red'),
    ('#4ECDC4', 'Teal'),
    ('#7D56F4', 'Purple'),
    ('#FFE66D', 'Yellow'),
    ('#45B7D1', 'Blue'),
  ];

  for (final (hex, name) in baseColors) {
    final base = lipColor(hex);
    final buf = StringBuffer();

    // Darken steps
    for (var i = 4; i >= 1; i--) {
      final darkened = darken(base, i * 0.15);
      buf.write(Style().background(darkened).render('  '));
    }

    // Base color
    buf.write(Style()
        .background(base)
        .foreground(isDarkColor(base) ? lipColor('#FFFFFF') : lipColor('#000000'))
        .render(' $name '));

    // Lighten steps
    for (var i = 1; i <= 4; i++) {
      final lightened = lighten(base, i * 0.15);
      buf.write(Style().background(lightened).render('  '));
    }

    print(buf);
  }

  print('');
  print(Style().faint().render('← darker    base    lighter →'));

  // isDarkColor demo
  print('');
  print('Dark color detection:');
  final testColors = [
    ('#000000', 'Black'),
    ('#333333', 'Dark Gray'),
    ('#888888', 'Mid Gray'),
    ('#CCCCCC', 'Light Gray'),
    ('#FFFFFF', 'White'),
  ];

  for (final (hex, name) in testColors) {
    final c = lipColor(hex);
    final dark = isDarkColor(c);
    final indicator = dark ? 'DARK' : 'LIGHT';
    print(Style()
        .background(c)
        .foreground(dark ? lipColor('#FFFFFF') : lipColor('#000000'))
        .padding(0, 1)
        .render('$name ($indicator)'));
  }
}
