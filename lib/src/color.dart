// Ported from charmbracelet/lipgloss color.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'dart:math' as math;

/// Base color type for terminal colors.
sealed class LipglossColor {
  const LipglossColor();

  /// Parse a color string. Accepts:
  /// - Hex: '#FF0000', '#F00', 'FF0000'
  /// - ANSI 256 index: '0' through '255'
  factory LipglossColor.parse(String s) {
    s = s.trim();
    if (s.isEmpty) return const NoColor();

    // Hex color
    if (s.startsWith('#') || (s.length == 6 && _isHex(s))) {
      return _parseHex(s);
    }

    // Try as ANSI index
    final index = int.tryParse(s);
    if (index != null && index >= 0 && index <= 255) {
      if (index < 16) return ANSIColor(index);
      return ANSI256Color(index);
    }

    return const NoColor();
  }

  /// Returns (r, g, b, a) as 0-255 values.
  ({int r, int g, int b, int a}) get rgba;
}

/// Absence of color — renders no color escape codes.
class NoColor extends LipglossColor {
  const NoColor();

  @override
  ({int r, int g, int b, int a}) get rgba => (r: 0, g: 0, b: 0, a: 0);

  @override
  bool operator ==(Object other) => other is NoColor;

  @override
  int get hashCode => 0;
}

/// ANSI 16 basic color (0-15).
class ANSIColor extends LipglossColor {
  final int value;
  const ANSIColor(this.value);

  @override
  ({int r, int g, int b, int a}) get rgba {
    final rgb = _ansi16ToRgb[value.clamp(0, 15)];
    return (r: rgb.$1, g: rgb.$2, b: rgb.$3, a: 255);
  }

  @override
  bool operator ==(Object other) => other is ANSIColor && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// ANSI 256 color (0-255).
class ANSI256Color extends LipglossColor {
  final int value;
  const ANSI256Color(this.value);

  @override
  ({int r, int g, int b, int a}) get rgba {
    if (value < 16) return ANSIColor(value).rgba;
    if (value >= 232) {
      // Grayscale: 232-255
      final g = 8 + (value - 232) * 10;
      return (r: g, g: g, b: g, a: 255);
    }
    // 6x6x6 color cube: 16-231 (xterm palette)
    const cubeLevels = [0, 95, 135, 175, 215, 255];
    final idx = value - 16;
    final r = cubeLevels[idx ~/ 36];
    final g = cubeLevels[(idx % 36) ~/ 6];
    final b = cubeLevels[idx % 6];
    return (r: r, g: g, b: b, a: 255);
  }

  @override
  bool operator ==(Object other) =>
      other is ANSI256Color && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// TrueColor RGB.
class RGBColor extends LipglossColor {
  final int r, g, b;
  const RGBColor(this.r, this.g, this.b);

  @override
  ({int r, int g, int b, int a}) get rgba => (r: r, g: g, b: b, a: 255);

  @override
  bool operator ==(Object other) =>
      other is RGBColor && r == other.r && g == other.g && b == other.b;

  @override
  int get hashCode => Object.hash(r, g, b);
}

// ─── Top-level factory ───

/// Parse a color string into a LipglossColor. Avoids collision with dart:ui Color.
///
/// Accepts hex strings ('#FF0000', '#F00'), or ANSI index ('0'-'255').
LipglossColor lipColor(String s) => LipglossColor.parse(s);

// ─── Named ANSI constants ───

const lipglossBlack = ANSIColor(0);
const lipglossRed = ANSIColor(1);
const lipglossGreen = ANSIColor(2);
const lipglossYellow = ANSIColor(3);
const lipglossBlue = ANSIColor(4);
const lipglossMagenta = ANSIColor(5);
const lipglossCyan = ANSIColor(6);
const lipglossWhite = ANSIColor(7);
const lipglossBrightBlack = ANSIColor(8);
const lipglossBrightRed = ANSIColor(9);
const lipglossBrightGreen = ANSIColor(10);
const lipglossBrightYellow = ANSIColor(11);
const lipglossBrightBlue = ANSIColor(12);
const lipglossBrightMagenta = ANSIColor(13);
const lipglossBrightCyan = ANSIColor(14);
const lipglossBrightWhite = ANSIColor(15);

// ─── Hex parser ───

bool _isHex(String s) => RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);

RGBColor _parseHex(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 3) {
    hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
  }
  final value = int.parse(hex, radix: 16);
  return RGBColor((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
}

// ─── ANSI 16 to RGB lookup ───

const _ansi16ToRgb = <(int, int, int)>[
  (0, 0, 0), // 0: Black
  (170, 0, 0), // 1: Red
  (0, 170, 0), // 2: Green
  (170, 170, 0), // 3: Yellow
  (0, 0, 170), // 4: Blue
  (170, 0, 170), // 5: Magenta
  (0, 170, 170), // 6: Cyan
  (170, 170, 170), // 7: White
  (85, 85, 85), // 8: Bright Black
  (255, 85, 85), // 9: Bright Red
  (85, 255, 85), // 10: Bright Green
  (255, 255, 85), // 11: Bright Yellow
  (85, 85, 255), // 12: Bright Blue
  (255, 85, 255), // 13: Bright Magenta
  (85, 255, 255), // 14: Bright Cyan
  (255, 255, 255), // 15: Bright White
];

// ─── Color utility functions ───

/// Set alpha on a color. Since terminal colors don't have true alpha,
/// this preserves the R/G/B values (matching Go's Alpha() behavior).
LipglossColor alpha(LipglossColor c, double a) {
  if (c is NoColor) return c;
  final rgba = c.rgba;
  return RGBColor(rgba.r, rgba.g, rgba.b);
}

/// Check if a color is dark (luminance < 0.5).
bool isDarkColor(LipglossColor c) {
  final rgba = c.rgba;
  // Relative luminance formula
  final r = rgba.r / 255.0;
  final g = rgba.g / 255.0;
  final b = rgba.b / 255.0;
  final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  return luminance < 0.5;
}

/// Get the complementary color by rotating hue 180° in HSV space.
LipglossColor complementary(LipglossColor c) {
  if (c is NoColor) return c;
  final rgba = c.rgba;
  final hsv = _rgbToHsv(rgba.r, rgba.g, rgba.b);
  final newH = (hsv.$1 + 180.0) % 360.0;
  final rgb = _hsvToRgb(newH, hsv.$2, hsv.$3);
  return RGBColor(rgb.$1, rgb.$2, rgb.$3);
}

/// Darken a color by [amount] (0.0 to 1.0).
LipglossColor darken(LipglossColor c, double amount) {
  final rgba = c.rgba;
  final factor = (1.0 - amount).clamp(0.0, 1.0);
  return RGBColor(
    (rgba.r * factor).round(),
    (rgba.g * factor).round(),
    (rgba.b * factor).round(),
  );
}

/// Lighten a color by [amount] (0.0 to 1.0).
LipglossColor lighten(LipglossColor c, double amount) {
  final rgba = c.rgba;
  return RGBColor(
    (rgba.r + (255 - rgba.r) * amount).round().clamp(0, 255),
    (rgba.g + (255 - rgba.g) * amount).round().clamp(0, 255),
    (rgba.b + (255 - rgba.b) * amount).round().clamp(0, 255),
  );
}

/// Downsample a TrueColor to the nearest ANSI 256 color.
ANSI256Color rgbToAnsi256(RGBColor c) {
  // Check grayscale first
  if (c.r == c.g && c.g == c.b) {
    if (c.r < 8) return const ANSI256Color(16);
    if (c.r > 248) return const ANSI256Color(231);
    return ANSI256Color(((c.r - 8) / 247.0 * 24.0).round() + 232);
  }

  // Map to 6x6x6 color cube (xterm levels: 0, 95, 135, 175, 215, 255)
  final ri = _nearestCubeIndex(c.r);
  final gi = _nearestCubeIndex(c.g);
  final bi = _nearestCubeIndex(c.b);
  return ANSI256Color(16 + 36 * ri + 6 * gi + bi);
}

const _cubeLevels = [0, 95, 135, 175, 215, 255];

int _nearestCubeIndex(int value) {
  var bestIdx = 0;
  var bestDist = (value - _cubeLevels[0]).abs();
  for (var i = 1; i < _cubeLevels.length; i++) {
    final dist = (value - _cubeLevels[i]).abs();
    if (dist < bestDist) {
      bestDist = dist;
      bestIdx = i;
    }
  }
  return bestIdx;
}

/// Downsample a color to the nearest ANSI 16 color.
ANSIColor rgbToAnsi16(LipglossColor c) {
  final rgba = c.rgba;
  var bestIdx = 0;
  var bestDist = double.maxFinite;

  for (var i = 0; i < 16; i++) {
    final ref = _ansi16ToRgb[i];
    final dr = rgba.r - ref.$1;
    final dg = rgba.g - ref.$2;
    final db = rgba.b - ref.$3;
    final dist = math.sqrt((dr * dr + dg * dg + db * db).toDouble());
    if (dist < bestDist) {
      bestDist = dist;
      bestIdx = i;
    }
  }

  return ANSIColor(bestIdx);
}

/// Adaptive color: returns light or dark variant based on terminal background.
LipglossColor adaptiveColor({
  required LipglossColor light,
  required LipglossColor dark,
  required bool hasDarkBackground,
}) {
  return hasDarkBackground ? dark : light;
}

/// Complete adaptive color: returns appropriate color for the detected color profile.
LipglossColor completeAdaptiveColor({
  required LipglossColor trueColor,
  required LipglossColor ansi256,
  required LipglossColor ansi,
  required int profileLevel,
}) {
  // profileLevel: 0=ascii, 1=ansi, 2=ansi256, 3=trueColor
  switch (profileLevel) {
    case 3:
      return trueColor;
    case 2:
      return ansi256;
    case 1:
      return ansi;
    default:
      return const NoColor();
  }
}

/// Returns a reusable function that selects light or dark color.
LipglossColor Function(LipglossColor light, LipglossColor dark) lightDark(
    bool isDark) {
  return (LipglossColor light, LipglossColor dark) => isDark ? dark : light;
}

// ─── HSV conversion helpers ───

/// RGB to HSV. Returns (h: 0-360, s: 0-1, v: 0-1).
(double, double, double) _rgbToHsv(int r, int g, int b) {
  final rn = r / 255.0;
  final gn = g / 255.0;
  final bn = b / 255.0;
  final cMax = math.max(rn, math.max(gn, bn));
  final cMin = math.min(rn, math.min(gn, bn));
  final delta = cMax - cMin;

  double h;
  if (delta == 0) {
    h = 0;
  } else if (cMax == rn) {
    h = 60.0 * (((gn - bn) / delta) % 6.0);
  } else if (cMax == gn) {
    h = 60.0 * (((bn - rn) / delta) + 2.0);
  } else {
    h = 60.0 * (((rn - gn) / delta) + 4.0);
  }
  if (h < 0) h += 360.0;

  final s = cMax == 0 ? 0.0 : delta / cMax;
  return (h, s, cMax);
}

/// HSV to RGB. h: 0-360, s: 0-1, v: 0-1. Returns (r, g, b) as 0-255.
(int, int, int) _hsvToRgb(double h, double s, double v) {
  final c = v * s;
  final x = c * (1.0 - ((h / 60.0) % 2.0 - 1.0).abs());
  final m = v - c;

  double rn, gn, bn;
  if (h < 60) {
    rn = c;
    gn = x;
    bn = 0;
  } else if (h < 120) {
    rn = x;
    gn = c;
    bn = 0;
  } else if (h < 180) {
    rn = 0;
    gn = c;
    bn = x;
  } else if (h < 240) {
    rn = 0;
    gn = x;
    bn = c;
  } else if (h < 300) {
    rn = x;
    gn = 0;
    bn = c;
  } else {
    rn = c;
    gn = 0;
    bn = x;
  }

  return (
    ((rn + m) * 255).round().clamp(0, 255),
    ((gn + m) * 255).round().clamp(0, 255),
    ((bn + m) * 255).round().clamp(0, 255),
  );
}
