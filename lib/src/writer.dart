// Ported from charmbracelet/lipgloss writer.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'dart:io';

import 'color.dart';

/// Terminal color profile.
enum ColorProfile {
  /// No color support.
  ascii,

  /// 16 colors (ANSI).
  ansi,

  /// 256 colors.
  ansi256,

  /// 16 million colors (TrueColor).
  trueColor,
}

/// Detect the terminal's color profile.
ColorProfile detectColorProfile([IOSink? output]) {
  // Check NO_COLOR env var → ascii
  if (Platform.environment.containsKey('NO_COLOR')) return ColorProfile.ascii;

  // Check FORCE_COLOR env var → at least ansi
  if (Platform.environment.containsKey('FORCE_COLOR')) {
    final level = Platform.environment['FORCE_COLOR'] ?? '';
    if (level == '3') return ColorProfile.trueColor;
    if (level == '2') return ColorProfile.ansi256;
    return ColorProfile.ansi;
  }

  // Check if stdout supports ANSI escapes
  if (output == null || output == stdout) {
    if (!stdout.supportsAnsiEscapes) return ColorProfile.ascii;
  }

  // Check COLORTERM for truecolor
  final colorterm = (Platform.environment['COLORTERM'] ?? '').toLowerCase();
  if (['truecolor', 'true-color', '24bit'].contains(colorterm)) {
    return ColorProfile.trueColor;
  }

  // Check TERM for 256color
  final term = Platform.environment['TERM'] ?? '';
  if (term.contains('256color')) return ColorProfile.ansi256;

  // Check if terminal is attached
  if (stdout.hasTerminal) return ColorProfile.ansi;

  return ColorProfile.ascii;
}

/// Downsample a LipglossColor to fit within [profile].
LipglossColor downsample(LipglossColor c, ColorProfile profile) {
  switch (c) {
    case NoColor():
      return c;
    case ANSIColor():
      if (profile == ColorProfile.ascii) return const NoColor();
      return c;
    case ANSI256Color():
      if (profile == ColorProfile.ascii) return const NoColor();
      if (profile == ColorProfile.ansi) return rgbToAnsi16(c);
      return c;
    case RGBColor():
      if (profile == ColorProfile.ascii) return const NoColor();
      if (profile == ColorProfile.ansi) return rgbToAnsi16(c);
      if (profile == ColorProfile.ansi256) return rgbToAnsi256(c);
      return c;
  }
}
