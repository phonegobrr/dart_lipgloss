// Ported from charmbracelet/lipgloss set.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Property keys as sequential integers for JS/web-safe bit operations.
/// Uses a two-integer Props class to support >30 property keys without
/// exceeding JavaScript's 32-bit signed integer limit for bitwise ops.
abstract final class PropKey {
  static const int bold = 0;
  static const int italic = 1;
  static const int underline = 2;
  static const int strikethrough = 3;
  static const int reverse = 4;
  static const int blink = 5;
  static const int faint = 6;
  static const int foreground = 7;
  static const int background = 8;
  static const int width = 9;
  static const int height = 10;
  static const int alignHorizontal = 11;
  static const int alignVertical = 12;
  static const int paddingTop = 13;
  static const int paddingRight = 14;
  static const int paddingBottom = 15;
  static const int paddingLeft = 16;
  static const int marginTop = 17;
  static const int marginRight = 18;
  static const int marginBottom = 19;
  static const int marginLeft = 20;
  static const int marginBackground = 21;
  static const int borderStyle = 22;
  static const int borderTop = 23;
  static const int borderRight = 24;
  static const int borderBottom = 25;
  static const int borderLeft = 26;
  static const int borderForeground = 27;
  static const int borderBackground = 28;
  static const int borderForegroundBlend = 29;
  // --- second integer starts here (key >= 30) ---
  static const int inline = 30;
  static const int maxWidth = 31;
  static const int maxHeight = 32;
  static const int tabWidth = 33;
  static const int underlineSpaces = 34;
  static const int strikethroughSpaces = 35;
  static const int colorWhitespace = 36;
  static const int transform = 37;
  static const int hyperlink = 38;
  static const int paddingChar = 39;
  static const int marginChar = 40;
  static const int underlineStyle = 41;
  static const int underlineColor = 42;
  // Per-side border colors (2a)
  static const int borderTopForeground = 43;
  static const int borderRightForeground = 44;
  static const int borderBottomForeground = 45;
  static const int borderLeftForeground = 46;
  static const int borderTopBackground = 47;
  static const int borderRightBackground = 48;
  static const int borderBottomBackground = 49;
  static const int borderLeftBackground = 50;
  // Border foreground blend offset (2b)
  static const int borderForegroundBlendOffset = 51;
  // Hyperlink params (2c)
  static const int hyperlinkParams = 52;
}

/// Tracks which properties have been explicitly set on a Style.
/// Uses two integers for JS/web-safe bitwise operations (max 30 bits each).
class Props {
  final int _bits1; // Keys 0-29
  final int _bits2; // Keys 30+

  const Props([this._bits1 = 0, this._bits2 = 0]);

  /// Set a property flag.
  Props set(int key) {
    if (key < 30) return Props(_bits1 | (1 << key), _bits2);
    return Props(_bits1, _bits2 | (1 << (key - 30)));
  }

  /// Unset a property flag.
  Props unset(int key) {
    if (key < 30) return Props(_bits1 & ~(1 << key), _bits2);
    return Props(_bits1, _bits2 & ~(1 << (key - 30)));
  }

  /// Check if a property flag is set.
  bool has(int key) {
    if (key < 30) return (_bits1 & (1 << key)) != 0;
    return (_bits2 & (1 << (key - 30))) != 0;
  }

  @override
  bool operator ==(Object other) =>
      other is Props && _bits1 == other._bits1 && _bits2 == other._bits2;

  @override
  int get hashCode => Object.hash(_bits1, _bits2);
}
