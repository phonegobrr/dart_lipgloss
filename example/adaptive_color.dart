// Port of lipgloss/examples/color/standalone/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  // Adaptive colors switch between light and dark terminal backgrounds.
  // Since we can't detect background at compile time in an example,
  // we demonstrate both variants.

  final lightFg = lipColor('#333333');
  final darkFg = lipColor('#DDDDDD');

  final lightBg = lipColor('#EEEEEE');
  final darkBg = lipColor('#1A1A2E');

  // Simulate dark background
  final darkStyle = Style()
      .foreground(adaptiveColor(
        light: lightFg,
        dark: darkFg,
        hasDarkBackground: true,
      ))
      .background(adaptiveColor(
        light: lightBg,
        dark: darkBg,
        hasDarkBackground: true,
      ))
      .padding(1, 2)
      .bold();

  // Simulate light background
  final lightStyle = Style()
      .foreground(adaptiveColor(
        light: lightFg,
        dark: darkFg,
        hasDarkBackground: false,
      ))
      .background(adaptiveColor(
        light: lightBg,
        dark: darkBg,
        hasDarkBackground: false,
      ))
      .padding(1, 2)
      .bold();

  print('Dark background mode:');
  print(darkStyle.render('Hello, adaptive colors!'));
  print('');
  print('Light background mode:');
  print(lightStyle.render('Hello, adaptive colors!'));
  print('');

  // Complete adaptive color (multi-profile)
  print('Profile-aware color:');
  final completeColor = completeAdaptiveColor(
    trueColor: lipColor('#7D56F4'),
    ansi256: ANSI256Color(135),
    ansi: lipglossMagenta,
    profileLevel: 3, // trueColor
  );
  print(Style()
      .foreground(completeColor)
      .bold()
      .render('  Works across color profiles  '));
}
