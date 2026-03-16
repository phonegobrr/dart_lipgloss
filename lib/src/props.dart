// Ported from charmbracelet/lipgloss set.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Property keys as bit flags, mirroring Go's propKey iota.
abstract final class PropKey {
  static const int bold = 1 << 0;
  static const int italic = 1 << 1;
  static const int underline = 1 << 2;
  static const int strikethrough = 1 << 3;
  static const int reverse = 1 << 4;
  static const int blink = 1 << 5;
  static const int faint = 1 << 6;
  static const int foreground = 1 << 7;
  static const int background = 1 << 8;
  static const int width = 1 << 9;
  static const int height = 1 << 10;
  static const int alignHorizontal = 1 << 11;
  static const int alignVertical = 1 << 12;
  static const int paddingTop = 1 << 13;
  static const int paddingRight = 1 << 14;
  static const int paddingBottom = 1 << 15;
  static const int paddingLeft = 1 << 16;
  static const int marginTop = 1 << 17;
  static const int marginRight = 1 << 18;
  static const int marginBottom = 1 << 19;
  static const int marginLeft = 1 << 20;
  static const int marginBackground = 1 << 21;
  static const int borderStyle = 1 << 22;
  static const int borderTop = 1 << 23;
  static const int borderRight = 1 << 24;
  static const int borderBottom = 1 << 25;
  static const int borderLeft = 1 << 26;
  static const int borderForeground = 1 << 27;
  static const int borderBackground = 1 << 28;
  static const int borderForegroundBlend = 1 << 29;
  static const int inline = 1 << 30;
  static const int maxWidth = 1 << 31;
  static const int maxHeight = 1 << 32;
  static const int tabWidth = 1 << 33;
  static const int underlineSpaces = 1 << 34;
  static const int strikethroughSpaces = 1 << 35;
  static const int colorWhitespace = 1 << 36;
  static const int transform = 1 << 37;
  static const int hyperlink = 1 << 38;
  static const int paddingChar = 1 << 39;
  static const int marginChar = 1 << 40;
  static const int underlineStyle = 1 << 41;
  static const int underlineColor = 1 << 42;
}

/// Tracks which properties have been explicitly set on a Style.
class Props {
  final int _bits;
  const Props([this._bits = 0]);

  /// Set a property flag.
  Props set(int key) => Props(_bits | key);

  /// Unset a property flag.
  Props unset(int key) => Props(_bits & ~key);

  /// Check if a property flag is set.
  bool has(int key) => (_bits & key) != 0;

  /// The raw bitfield value.
  int get bits => _bits;

  @override
  bool operator ==(Object other) => other is Props && _bits == other._bits;

  @override
  int get hashCode => _bits.hashCode;
}
