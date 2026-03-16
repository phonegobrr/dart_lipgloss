// Ported from charmbracelet/x/ansi
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import '../color.dart';

/// ANSI SGR reset sequence.
const resetSequence = '\x1b[0m';

/// Underline style variants.
enum UnderlineStyle {
  none,
  single,
  double_,
  curly,
  dotted,
  dashed,
}

/// Builder for ANSI SGR (Select Graphic Rendition) escape sequences.
class AnsiStyle {
  bool _bold = false;
  bool _italic = false;
  bool _faint = false;
  bool _blink = false;
  bool _reverse = false;
  bool _strikethrough = false;
  UnderlineStyle _underline = UnderlineStyle.none;
  LipglossColor? _fg;
  LipglossColor? _bg;
  LipglossColor? _underlineColor;

  AnsiStyle();

  AnsiStyle setBold([bool v = true]) {
    _bold = v;
    return this;
  }

  AnsiStyle setItalic([bool v = true]) {
    _italic = v;
    return this;
  }

  AnsiStyle setFaint([bool v = true]) {
    _faint = v;
    return this;
  }

  AnsiStyle setBlink([bool v = true]) {
    _blink = v;
    return this;
  }

  AnsiStyle setReverse([bool v = true]) {
    _reverse = v;
    return this;
  }

  AnsiStyle setStrikethrough([bool v = true]) {
    _strikethrough = v;
    return this;
  }

  AnsiStyle setUnderline(UnderlineStyle style) {
    _underline = style;
    return this;
  }

  AnsiStyle setForeground(LipglossColor? c) {
    _fg = c;
    return this;
  }

  AnsiStyle setBackground(LipglossColor? c) {
    _bg = c;
    return this;
  }

  AnsiStyle setUnderlineColor(LipglossColor? c) {
    _underlineColor = c;
    return this;
  }

  /// Build the SGR parameter string (without ESC[ prefix or m suffix).
  String _buildParams() {
    final params = <String>[];

    if (_bold) params.add('1');
    if (_faint) params.add('2');
    if (_italic) params.add('3');

    switch (_underline) {
      case UnderlineStyle.none:
        break;
      case UnderlineStyle.single:
        params.add('4');
      case UnderlineStyle.double_:
        params.add('4:2');
      case UnderlineStyle.curly:
        params.add('4:3');
      case UnderlineStyle.dotted:
        params.add('4:4');
      case UnderlineStyle.dashed:
        params.add('4:5');
    }

    if (_blink) params.add('5');
    if (_reverse) params.add('7');
    if (_strikethrough) params.add('9');

    if (_fg != null) {
      final fgParams = _colorToSgrParams(_fg!, foreground: true);
      if (fgParams.isNotEmpty) params.add(fgParams);
    }

    if (_bg != null) {
      final bgParams = _colorToSgrParams(_bg!, foreground: false);
      if (bgParams.isNotEmpty) params.add(bgParams);
    }

    if (_underlineColor != null) {
      final ucParams = _underlineColorToSgr(_underlineColor!);
      if (ucParams.isNotEmpty) params.add(ucParams);
    }

    return params.join(';');
  }

  /// Wrap [s] in ANSI escape sequences for this style.
  String styled(String s) {
    final params = _buildParams();
    if (params.isEmpty) return s;
    return '\x1b[${params}m$s$resetSequence';
  }

  /// Returns just the opening escape sequence (no reset).
  String get openSequence {
    final params = _buildParams();
    if (params.isEmpty) return '';
    return '\x1b[${params}m';
  }

  bool get hasStyle =>
      _bold ||
      _italic ||
      _faint ||
      _blink ||
      _reverse ||
      _strikethrough ||
      _underline != UnderlineStyle.none ||
      _fg != null ||
      _bg != null ||
      _underlineColor != null;
}

/// Convert a LipglossColor to SGR parameters for foreground or background.
String _colorToSgrParams(LipglossColor c, {required bool foreground}) {
  switch (c) {
    case NoColor():
      return '';
    case ANSIColor():
      final base = foreground ? 30 : 40;
      if (c.value < 8) {
        return '${base + c.value}';
      } else {
        return '${base + 60 + c.value - 8}';
      }
    case ANSI256Color():
      final prefix = foreground ? '38' : '48';
      return '$prefix;5;${c.value}';
    case RGBColor():
      final prefix = foreground ? '38' : '48';
      return '$prefix;2;${c.r};${c.g};${c.b}';
  }
}

/// Convert a LipglossColor to SGR underline color parameter.
String _underlineColorToSgr(LipglossColor c) {
  switch (c) {
    case NoColor():
      return '';
    case ANSIColor():
      return '58;5;${c.value}';
    case ANSI256Color():
      return '58;5;${c.value}';
    case RGBColor():
      return '58;2;${c.r};${c.g};${c.b}';
  }
}
