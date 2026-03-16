// Ported from charmbracelet/lipgloss style.go, set.go, get.go, unset.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'package:meta/meta.dart';

import 'align.dart';
import 'ansi/hyperlink.dart' as hl;
import 'ansi/sgr.dart';
import 'ansi/truncate.dart' as trunc;
import 'ansi/width.dart';
import 'blending.dart';
import 'border.dart';
import 'color.dart';
import 'props.dart';
import 'whitespace.dart';
import 'wrap.dart';

/// Tab conversion constant. Set tab width to this to disable tab conversion.
const noTabConversion = -1;

/// Non-breaking space constant.
const nbsp = '\u00A0';

/// The core style engine. Immutable — every builder method returns a new instance.
@immutable
class Style {
  final Props _props;

  // Formatting
  final bool _bold;
  final bool _italic;
  final bool _faint;
  final bool _blink;
  final bool _reverse;
  final bool _strikethrough;
  final UnderlineStyle _underlineStyle;
  final LipglossColor _underlineColor;

  // Colors
  final LipglossColor _foreground;
  final LipglossColor _background;
  final LipglossColor _marginBackground;

  // Dimensions
  final int _width;
  final int _height;
  final int _maxWidth;
  final int _maxHeight;

  // Layout
  final double _alignHorizontal;
  final double _alignVertical;
  final int _paddingTop;
  final int _paddingRight;
  final int _paddingBottom;
  final int _paddingLeft;
  final int _marginTop;
  final int _marginRight;
  final int _marginBottom;
  final int _marginLeft;
  final String _paddingChar;
  final String _marginChar;

  // Borders
  final Border _borderStyle;
  final bool _borderTop;
  final bool _borderRight;
  final bool _borderBottom;
  final bool _borderLeft;
  final LipglossColor _borderForeground;
  final LipglossColor _borderBackground;
  final List<LipglossColor>? _borderForegroundBlend;
  // Per-side border colors
  final LipglossColor _borderTopForeground;
  final LipglossColor _borderRightForeground;
  final LipglossColor _borderBottomForeground;
  final LipglossColor _borderLeftForeground;
  final LipglossColor _borderTopBackground;
  final LipglossColor _borderRightBackground;
  final LipglossColor _borderBottomBackground;
  final LipglossColor _borderLeftBackground;
  final int _borderForegroundBlendOffset;

  // Behavior
  final bool _inline;
  final int _tabWidth;
  final bool _underlineSpaces;
  final bool _strikethroughSpaces;
  final bool _colorWhitespace;
  final String Function(String)? _transform;
  final String? _hyperlink;
  final Map<String, String>? _hyperlinkParams;

  // Internal: string value (from SetString)
  final String? _value;

  const Style._({
    Props props = const Props(),
    bool bold = false,
    bool italic = false,
    bool faint = false,
    bool blink = false,
    bool reverse = false,
    bool strikethrough = false,
    UnderlineStyle underlineStyle = UnderlineStyle.none,
    LipglossColor underlineColor = const NoColor(),
    LipglossColor foreground = const NoColor(),
    LipglossColor background = const NoColor(),
    LipglossColor marginBackground = const NoColor(),
    int width = 0,
    int height = 0,
    int maxWidth = 0,
    int maxHeight = 0,
    double alignHorizontal = 0.0,
    double alignVertical = 0.0,
    int paddingTop = 0,
    int paddingRight = 0,
    int paddingBottom = 0,
    int paddingLeft = 0,
    int marginTop = 0,
    int marginRight = 0,
    int marginBottom = 0,
    int marginLeft = 0,
    String paddingChar = ' ',
    String marginChar = ' ',
    Border borderStyle = noBorder,
    bool borderTop = false,
    bool borderRight = false,
    bool borderBottom = false,
    bool borderLeft = false,
    LipglossColor borderForeground = const NoColor(),
    LipglossColor borderBackground = const NoColor(),
    List<LipglossColor>? borderForegroundBlend,
    LipglossColor borderTopForeground = const NoColor(),
    LipglossColor borderRightForeground = const NoColor(),
    LipglossColor borderBottomForeground = const NoColor(),
    LipglossColor borderLeftForeground = const NoColor(),
    LipglossColor borderTopBackground = const NoColor(),
    LipglossColor borderRightBackground = const NoColor(),
    LipglossColor borderBottomBackground = const NoColor(),
    LipglossColor borderLeftBackground = const NoColor(),
    int borderForegroundBlendOffset = 0,
    bool inline = false,
    int tabWidth = 4,
    bool underlineSpaces = false,
    bool strikethroughSpaces = false,
    bool colorWhitespace = true,
    String Function(String)? transform,
    String? hyperlink,
    Map<String, String>? hyperlinkParams,
    String? value,
  })  : _props = props,
        _bold = bold,
        _italic = italic,
        _faint = faint,
        _blink = blink,
        _reverse = reverse,
        _strikethrough = strikethrough,
        _underlineStyle = underlineStyle,
        _underlineColor = underlineColor,
        _foreground = foreground,
        _background = background,
        _marginBackground = marginBackground,
        _width = width,
        _height = height,
        _maxWidth = maxWidth,
        _maxHeight = maxHeight,
        _alignHorizontal = alignHorizontal,
        _alignVertical = alignVertical,
        _paddingTop = paddingTop,
        _paddingRight = paddingRight,
        _paddingBottom = paddingBottom,
        _paddingLeft = paddingLeft,
        _marginTop = marginTop,
        _marginRight = marginRight,
        _marginBottom = marginBottom,
        _marginLeft = marginLeft,
        _paddingChar = paddingChar,
        _marginChar = marginChar,
        _borderStyle = borderStyle,
        _borderTop = borderTop,
        _borderRight = borderRight,
        _borderBottom = borderBottom,
        _borderLeft = borderLeft,
        _borderForeground = borderForeground,
        _borderBackground = borderBackground,
        _borderForegroundBlend = borderForegroundBlend,
        _borderTopForeground = borderTopForeground,
        _borderRightForeground = borderRightForeground,
        _borderBottomForeground = borderBottomForeground,
        _borderLeftForeground = borderLeftForeground,
        _borderTopBackground = borderTopBackground,
        _borderRightBackground = borderRightBackground,
        _borderBottomBackground = borderBottomBackground,
        _borderLeftBackground = borderLeftBackground,
        _borderForegroundBlendOffset = borderForegroundBlendOffset,
        _inline = inline,
        _tabWidth = tabWidth,
        _underlineSpaces = underlineSpaces,
        _strikethroughSpaces = strikethroughSpaces,
        _colorWhitespace = colorWhitespace,
        _transform = transform,
        _hyperlink = hyperlink,
        _hyperlinkParams = hyperlinkParams,
        _value = value;

  /// Create a new empty Style.
  const Style() : this._();

  // ─── Builder Methods (each returns new Style) ───

  Style bold([bool v = true]) => _copyWith(
        props: _props.set(PropKey.bold),
        bold: v,
      );

  Style italic([bool v = true]) => _copyWith(
        props: _props.set(PropKey.italic),
        italic: v,
      );

  Style faint([bool v = true]) => _copyWith(
        props: _props.set(PropKey.faint),
        faint: v,
      );

  Style blink([bool v = true]) => _copyWith(
        props: _props.set(PropKey.blink),
        blink: v,
      );

  Style reverse([bool v = true]) => _copyWith(
        props: _props.set(PropKey.reverse),
        reverse: v,
      );

  Style strikethrough([bool v = true]) => _copyWith(
        props: _props.set(PropKey.strikethrough),
        strikethrough: v,
      );

  Style underline(UnderlineStyle style) => _copyWith(
        props: _props.set(PropKey.underlineStyle),
        underlineStyle: style,
      );

  /// Convenience: set underline on/off (maps to single/none).
  Style underlineBool(bool v) =>
      underline(v ? UnderlineStyle.single : UnderlineStyle.none);

  Style underlineColor(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.underlineColor),
        underlineColor: c,
      );

  Style foreground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.foreground),
        foreground: c,
      );

  Style background(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.background),
        background: c,
      );

  Style marginBackground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.marginBackground),
        marginBackground: c,
      );

  Style width(int w) => _copyWith(
        props: _props.set(PropKey.width),
        width: w,
      );

  Style height(int h) => _copyWith(
        props: _props.set(PropKey.height),
        height: h,
      );

  Style maxWidth(int w) => _copyWith(
        props: _props.set(PropKey.maxWidth),
        maxWidth: w,
      );

  Style maxHeight(int h) => _copyWith(
        props: _props.set(PropKey.maxHeight),
        maxHeight: h,
      );

  /// CSS-style shorthand: 1 arg = all, 2 = vert/horiz, 3 = top/horiz/bottom, 4 = top/right/bottom/left
  Style padding(int top, [int? right, int? bottom, int? left]) {
    final sides = _whichSidesInt(top, right, bottom, left);
    return _copyWith(
      props: _props
          .set(PropKey.paddingTop)
          .set(PropKey.paddingRight)
          .set(PropKey.paddingBottom)
          .set(PropKey.paddingLeft),
      paddingTop: sides.top,
      paddingRight: sides.right,
      paddingBottom: sides.bottom,
      paddingLeft: sides.left,
    );
  }

  Style paddingTop(int v) => _copyWith(
        props: _props.set(PropKey.paddingTop),
        paddingTop: v,
      );

  Style paddingRight(int v) => _copyWith(
        props: _props.set(PropKey.paddingRight),
        paddingRight: v,
      );

  Style paddingBottom(int v) => _copyWith(
        props: _props.set(PropKey.paddingBottom),
        paddingBottom: v,
      );

  Style paddingLeft(int v) => _copyWith(
        props: _props.set(PropKey.paddingLeft),
        paddingLeft: v,
      );

  /// CSS-style shorthand for margin.
  Style margin(int top, [int? right, int? bottom, int? left]) {
    final sides = _whichSidesInt(top, right, bottom, left);
    return _copyWith(
      props: _props
          .set(PropKey.marginTop)
          .set(PropKey.marginRight)
          .set(PropKey.marginBottom)
          .set(PropKey.marginLeft),
      marginTop: sides.top,
      marginRight: sides.right,
      marginBottom: sides.bottom,
      marginLeft: sides.left,
    );
  }

  Style marginTop(int v) => _copyWith(
        props: _props.set(PropKey.marginTop),
        marginTop: v,
      );

  Style marginRight(int v) => _copyWith(
        props: _props.set(PropKey.marginRight),
        marginRight: v,
      );

  Style marginBottom(int v) => _copyWith(
        props: _props.set(PropKey.marginBottom),
        marginBottom: v,
      );

  Style marginLeft(int v) => _copyWith(
        props: _props.set(PropKey.marginLeft),
        marginLeft: v,
      );

  /// Set border style and side flags. CSS-like shorthand for booleans:
  /// 1 arg = all sides, 2 = vert/horiz, 3 = top/horiz/bottom, 4 = top/right/bottom/left
  Style border(Border b, [bool? top, bool? right, bool? bottom, bool? left]) {
    var p = _props.set(PropKey.borderStyle);

    if (top == null && right == null && bottom == null && left == null) {
      // No side args: set style only, don't set side flags
      return _copyWith(props: p, borderStyle: b);
    }

    final sides = _whichSidesBool(top!, right, bottom, left);
    p = p
        .set(PropKey.borderTop)
        .set(PropKey.borderRight)
        .set(PropKey.borderBottom)
        .set(PropKey.borderLeft);

    return _copyWith(
      props: p,
      borderStyle: b,
      borderTop: sides.top,
      borderRight: sides.right,
      borderBottom: sides.bottom,
      borderLeft: sides.left,
    );
  }

  Style borderStyle(Border b) => _copyWith(
        props: _props.set(PropKey.borderStyle),
        borderStyle: b,
      );

  Style borderTop(bool v) => _copyWith(
        props: _props.set(PropKey.borderTop),
        borderTop: v,
      );

  Style borderRight(bool v) => _copyWith(
        props: _props.set(PropKey.borderRight),
        borderRight: v,
      );

  Style borderBottom(bool v) => _copyWith(
        props: _props.set(PropKey.borderBottom),
        borderBottom: v,
      );

  Style borderLeft(bool v) => _copyWith(
        props: _props.set(PropKey.borderLeft),
        borderLeft: v,
      );

  /// Set border foreground as CSS-style shorthand (1-4 args).
  Style borderForeground(LipglossColor c,
      [LipglossColor? c2, LipglossColor? c3, LipglossColor? c4]) {
    final sides = _whichSidesColor(c, c2, c3, c4);
    return _copyWith(
      props: _props
          .set(PropKey.borderTopForeground)
          .set(PropKey.borderRightForeground)
          .set(PropKey.borderBottomForeground)
          .set(PropKey.borderLeftForeground),
      borderTopForeground: sides.top,
      borderRightForeground: sides.right,
      borderBottomForeground: sides.bottom,
      borderLeftForeground: sides.left,
    );
  }

  /// Set border background as CSS-style shorthand (1-4 args).
  Style borderBackground(LipglossColor c,
      [LipglossColor? c2, LipglossColor? c3, LipglossColor? c4]) {
    final sides = _whichSidesColor(c, c2, c3, c4);
    return _copyWith(
      props: _props
          .set(PropKey.borderTopBackground)
          .set(PropKey.borderRightBackground)
          .set(PropKey.borderBottomBackground)
          .set(PropKey.borderLeftBackground),
      borderTopBackground: sides.top,
      borderRightBackground: sides.right,
      borderBottomBackground: sides.bottom,
      borderLeftBackground: sides.left,
    );
  }

  Style borderTopForeground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderTopForeground),
        borderTopForeground: c,
      );
  Style borderRightForeground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderRightForeground),
        borderRightForeground: c,
      );
  Style borderBottomForeground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderBottomForeground),
        borderBottomForeground: c,
      );
  Style borderLeftForeground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderLeftForeground),
        borderLeftForeground: c,
      );
  Style borderTopBackground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderTopBackground),
        borderTopBackground: c,
      );
  Style borderRightBackground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderRightBackground),
        borderRightBackground: c,
      );
  Style borderBottomBackground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderBottomBackground),
        borderBottomBackground: c,
      );
  Style borderLeftBackground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderLeftBackground),
        borderLeftBackground: c,
      );

  Style borderForegroundBlend(List<LipglossColor> colors) => _copyWith(
        props: _props.set(PropKey.borderForegroundBlend),
        borderForegroundBlend: colors,
      );

  Style borderForegroundBlendOffset(int v) => _copyWith(
        props: _props.set(PropKey.borderForegroundBlendOffset),
        borderForegroundBlendOffset: v,
      );

  /// Set alignment. 1 arg = horizontal only. 2 args = horizontal + vertical.
  Style align(double horizontal, [double? vertical]) {
    if (vertical == null) {
      return _copyWith(
        props: _props.set(PropKey.alignHorizontal),
        alignHorizontal: horizontal,
      );
    }
    return _copyWith(
      props: _props.set(PropKey.alignHorizontal).set(PropKey.alignVertical),
      alignHorizontal: horizontal,
      alignVertical: vertical,
    );
  }

  Style alignHorizontal(double v) => _copyWith(
        props: _props.set(PropKey.alignHorizontal),
        alignHorizontal: v,
      );

  Style alignVertical(double v) => _copyWith(
        props: _props.set(PropKey.alignVertical),
        alignVertical: v,
      );

  /// Set inline mode (strips newlines, skips layout).
  // ignore: non_constant_identifier_names
  Style inline([bool v = true]) => _copyWith(
        props: _props.set(PropKey.inline),
        inline: v,
      );

  Style tabWidth(int w) => _copyWith(
        props: _props.set(PropKey.tabWidth),
        tabWidth: w,
      );

  Style underlineSpaces([bool v = true]) => _copyWith(
        props: _props.set(PropKey.underlineSpaces),
        underlineSpaces: v,
      );

  Style strikethroughSpaces([bool v = true]) => _copyWith(
        props: _props.set(PropKey.strikethroughSpaces),
        strikethroughSpaces: v,
      );

  Style colorWhitespace([bool v = true]) => _copyWith(
        props: _props.set(PropKey.colorWhitespace),
        colorWhitespace: v,
      );

  Style transform(String Function(String) fn) => _copyWith(
        props: _props.set(PropKey.transform),
        transform: fn,
      );

  Style setHyperlink(String url, [Map<String, String>? params]) => _copyWith(
        props: params != null
            ? _props.set(PropKey.hyperlink).set(PropKey.hyperlinkParams)
            : _props.set(PropKey.hyperlink),
        hyperlink: url,
        hyperlinkParams: params,
      );

  Style paddingChar(String c) => _copyWith(
        props: _props.set(PropKey.paddingChar),
        paddingChar: c,
      );

  Style marginChar(String c) => _copyWith(
        props: _props.set(PropKey.marginChar),
        marginChar: c,
      );

  /// Set the string value. Multiple strings are joined with spaces.
  Style setString(String s, [List<String>? more]) {
    final joined = more != null ? [s, ...more].join(' ') : s;
    return _copyWith(value: joined);
  }

  /// Clear the string value.
  Style unsetString() => _copyWith(clearValue: true);

  // ─── Getters ───

  bool get getBold => _props.has(PropKey.bold) ? _bold : false;
  bool get getItalic => _props.has(PropKey.italic) ? _italic : false;
  bool get getFaint => _props.has(PropKey.faint) ? _faint : false;
  bool get getBlink => _props.has(PropKey.blink) ? _blink : false;
  bool get getReverse => _props.has(PropKey.reverse) ? _reverse : false;
  bool get getStrikethrough =>
      _props.has(PropKey.strikethrough) ? _strikethrough : false;
  UnderlineStyle get getUnderlineStyle => _props.has(PropKey.underlineStyle)
      ? _underlineStyle
      : UnderlineStyle.none;
  LipglossColor get getUnderlineColor =>
      _props.has(PropKey.underlineColor) ? _underlineColor : const NoColor();
  LipglossColor get getForeground =>
      _props.has(PropKey.foreground) ? _foreground : const NoColor();
  LipglossColor get getBackground =>
      _props.has(PropKey.background) ? _background : const NoColor();
  LipglossColor get getMarginBackground => _props.has(PropKey.marginBackground)
      ? _marginBackground
      : const NoColor();
  int get getWidth => _props.has(PropKey.width) ? _width : 0;
  int get getHeight => _props.has(PropKey.height) ? _height : 0;
  int get getMaxWidth => _props.has(PropKey.maxWidth) ? _maxWidth : 0;
  int get getMaxHeight => _props.has(PropKey.maxHeight) ? _maxHeight : 0;
  double get getAlignHorizontal =>
      _props.has(PropKey.alignHorizontal) ? _alignHorizontal : 0.0;
  double get getAlignVertical =>
      _props.has(PropKey.alignVertical) ? _alignVertical : 0.0;
  int get getPaddingTop => _props.has(PropKey.paddingTop) ? _paddingTop : 0;
  int get getPaddingRight =>
      _props.has(PropKey.paddingRight) ? _paddingRight : 0;
  int get getPaddingBottom =>
      _props.has(PropKey.paddingBottom) ? _paddingBottom : 0;
  int get getPaddingLeft => _props.has(PropKey.paddingLeft) ? _paddingLeft : 0;
  int get getMarginTop => _props.has(PropKey.marginTop) ? _marginTop : 0;
  int get getMarginRight => _props.has(PropKey.marginRight) ? _marginRight : 0;
  int get getMarginBottom =>
      _props.has(PropKey.marginBottom) ? _marginBottom : 0;
  int get getMarginLeft => _props.has(PropKey.marginLeft) ? _marginLeft : 0;
  Border get getBorderStyle =>
      _props.has(PropKey.borderStyle) ? _borderStyle : noBorder;
  bool get getBorderTop => _props.has(PropKey.borderTop) ? _borderTop : false;
  bool get getBorderRight =>
      _props.has(PropKey.borderRight) ? _borderRight : false;
  bool get getBorderBottom =>
      _props.has(PropKey.borderBottom) ? _borderBottom : false;
  bool get getBorderLeft =>
      _props.has(PropKey.borderLeft) ? _borderLeft : false;
  LipglossColor get getBorderForeground => _props.has(PropKey.borderForeground)
      ? _borderForeground
      : const NoColor();
  LipglossColor get getBorderBackground => _props.has(PropKey.borderBackground)
      ? _borderBackground
      : const NoColor();
  bool get getInline => _props.has(PropKey.inline) ? _inline : false;
  int get getTabWidth => _props.has(PropKey.tabWidth) ? _tabWidth : 4;
  bool get getUnderlineSpaces =>
      _props.has(PropKey.underlineSpaces) ? _underlineSpaces : false;
  bool get getStrikethroughSpaces =>
      _props.has(PropKey.strikethroughSpaces) ? _strikethroughSpaces : false;
  bool get getColorWhitespace =>
      _props.has(PropKey.colorWhitespace) ? _colorWhitespace : true;
  String? get getHyperlink => _props.has(PropKey.hyperlink) ? _hyperlink : null;
  Map<String, String>? get getHyperlinkParams =>
      _props.has(PropKey.hyperlinkParams) ? _hyperlinkParams : null;
  String? get getValue => _value;
  String get getPaddingChar =>
      _props.has(PropKey.paddingChar) ? _paddingChar : ' ';
  String get getMarginChar =>
      _props.has(PropKey.marginChar) ? _marginChar : ' ';
  String Function(String)? get getTransform =>
      _props.has(PropKey.transform) ? _transform : null;
  bool get getUnderline => getUnderlineStyle != UnderlineStyle.none;

  // Per-side border color getters
  LipglossColor get getBorderTopForeground =>
      _props.has(PropKey.borderTopForeground)
          ? _borderTopForeground
          : getBorderForeground;
  LipglossColor get getBorderRightForeground =>
      _props.has(PropKey.borderRightForeground)
          ? _borderRightForeground
          : getBorderForeground;
  LipglossColor get getBorderBottomForeground =>
      _props.has(PropKey.borderBottomForeground)
          ? _borderBottomForeground
          : getBorderForeground;
  LipglossColor get getBorderLeftForeground =>
      _props.has(PropKey.borderLeftForeground)
          ? _borderLeftForeground
          : getBorderForeground;
  LipglossColor get getBorderTopBackground =>
      _props.has(PropKey.borderTopBackground)
          ? _borderTopBackground
          : getBorderBackground;
  LipglossColor get getBorderRightBackground =>
      _props.has(PropKey.borderRightBackground)
          ? _borderRightBackground
          : getBorderBackground;
  LipglossColor get getBorderBottomBackground =>
      _props.has(PropKey.borderBottomBackground)
          ? _borderBottomBackground
          : getBorderBackground;
  LipglossColor get getBorderLeftBackground =>
      _props.has(PropKey.borderLeftBackground)
          ? _borderLeftBackground
          : getBorderBackground;
  int get getBorderForegroundBlendOffset =>
      _props.has(PropKey.borderForegroundBlendOffset)
          ? _borderForegroundBlendOffset
          : 0;
  List<LipglossColor>? get getBorderForegroundBlend =>
      _props.has(PropKey.borderForegroundBlend) ? _borderForegroundBlend : null;

  // Convenience aggregate getters
  int get getHorizontalPadding => getPaddingLeft + getPaddingRight;
  int get getVerticalPadding => getPaddingTop + getPaddingBottom;
  int get getHorizontalMargins => getMarginLeft + getMarginRight;
  int get getVerticalMargins => getMarginTop + getMarginBottom;
  (double, double) get getAlign => (getAlignHorizontal, getAlignVertical);
  Border get getBorder => getBorderStyle;
  (int, int, int, int) get getMargin =>
      (getMarginTop, getMarginRight, getMarginBottom, getMarginLeft);
  (int, int, int, int) get getPadding =>
      (getPaddingTop, getPaddingRight, getPaddingBottom, getPaddingLeft);

  /// Whether border style is set but no individual side flags are set.
  bool get _isBorderStyleSetWithoutSides {
    final b = getBorderStyle;
    final topSet = _props.has(PropKey.borderTop);
    final rightSet = _props.has(PropKey.borderRight);
    final bottomSet = _props.has(PropKey.borderBottom);
    final leftSet = _props.has(PropKey.borderLeft);
    return b != noBorder && !(topSet || rightSet || bottomSet || leftSet);
  }

  // Per-side border size getters accounting for _isBorderStyleSetWithoutSides
  int get getBorderTopSize {
    if (getBorderTop || _isBorderStyleSetWithoutSides) {
      return getBorderStyle.getTopSize();
    }
    return 0;
  }

  int get getBorderBottomSize {
    if (getBorderBottom || _isBorderStyleSetWithoutSides) {
      return getBorderStyle.getBottomSize();
    }
    return 0;
  }

  int get getBorderLeftSize {
    if (getBorderLeft || _isBorderStyleSetWithoutSides) {
      return getBorderStyle.getLeftSize();
    }
    return 0;
  }

  int get getBorderRightSize {
    if (getBorderRight || _isBorderStyleSetWithoutSides) {
      return getBorderStyle.getRightSize();
    }
    return 0;
  }

  int get getHorizontalBorderSize => getBorderLeftSize + getBorderRightSize;
  int get getVerticalBorderSize => getBorderTopSize + getBorderBottomSize;

  /// Total horizontal frame size (margins + borders + padding).
  int get getHorizontalFrameSize {
    return getMarginLeft +
        getMarginRight +
        getPaddingLeft +
        getPaddingRight +
        getBorderLeftSize +
        getBorderRightSize;
  }

  /// Total vertical frame size (margins + borders + padding).
  int get getVerticalFrameSize {
    return getMarginTop +
        getMarginBottom +
        getPaddingTop +
        getPaddingBottom +
        getBorderTopSize +
        getBorderBottomSize;
  }

  /// Frame size as (width, height).
  (int, int) get getFrameSize => (getHorizontalFrameSize, getVerticalFrameSize);

  // ─── Unsetters ───

  Style unsetBold() => _copyWith(props: _props.unset(PropKey.bold));
  Style unsetItalic() => _copyWith(props: _props.unset(PropKey.italic));
  Style unsetFaint() => _copyWith(props: _props.unset(PropKey.faint));
  Style unsetBlink() => _copyWith(props: _props.unset(PropKey.blink));
  Style unsetReverse() => _copyWith(props: _props.unset(PropKey.reverse));
  Style unsetStrikethrough() =>
      _copyWith(props: _props.unset(PropKey.strikethrough));
  Style unsetUnderlineStyle() =>
      _copyWith(props: _props.unset(PropKey.underlineStyle));
  Style unsetUnderline() =>
      _copyWith(props: _props.unset(PropKey.underlineStyle));
  Style unsetForeground() => _copyWith(props: _props.unset(PropKey.foreground));
  Style unsetBackground() => _copyWith(props: _props.unset(PropKey.background));
  Style unsetWidth() => _copyWith(props: _props.unset(PropKey.width));
  Style unsetHeight() => _copyWith(props: _props.unset(PropKey.height));
  Style unsetMaxWidth() => _copyWith(props: _props.unset(PropKey.maxWidth));
  Style unsetMaxHeight() => _copyWith(props: _props.unset(PropKey.maxHeight));
  Style unsetAlignHorizontal() =>
      _copyWith(props: _props.unset(PropKey.alignHorizontal));
  Style unsetAlignVertical() =>
      _copyWith(props: _props.unset(PropKey.alignVertical));
  Style unsetAlign() => _copyWith(
      props:
          _props.unset(PropKey.alignHorizontal).unset(PropKey.alignVertical));
  Style unsetPaddingTop() => _copyWith(props: _props.unset(PropKey.paddingTop));
  Style unsetPaddingRight() =>
      _copyWith(props: _props.unset(PropKey.paddingRight));
  Style unsetPaddingBottom() =>
      _copyWith(props: _props.unset(PropKey.paddingBottom));
  Style unsetPaddingLeft() =>
      _copyWith(props: _props.unset(PropKey.paddingLeft));
  Style unsetPadding() => _copyWith(
      props: _props
          .unset(PropKey.paddingTop)
          .unset(PropKey.paddingRight)
          .unset(PropKey.paddingBottom)
          .unset(PropKey.paddingLeft)
          .unset(PropKey.paddingChar));
  Style unsetMarginTop() => _copyWith(props: _props.unset(PropKey.marginTop));
  Style unsetMarginRight() =>
      _copyWith(props: _props.unset(PropKey.marginRight));
  Style unsetMarginBottom() =>
      _copyWith(props: _props.unset(PropKey.marginBottom));
  Style unsetMarginLeft() => _copyWith(props: _props.unset(PropKey.marginLeft));
  Style unsetMargins() => _copyWith(
      props: _props
          .unset(PropKey.marginTop)
          .unset(PropKey.marginRight)
          .unset(PropKey.marginBottom)
          .unset(PropKey.marginLeft)
          .unset(PropKey.marginChar));
  Style unsetBorderStyle() =>
      _copyWith(props: _props.unset(PropKey.borderStyle));
  Style unsetBorderTop() => _copyWith(props: _props.unset(PropKey.borderTop));
  Style unsetBorderRight() =>
      _copyWith(props: _props.unset(PropKey.borderRight));
  Style unsetBorderBottom() =>
      _copyWith(props: _props.unset(PropKey.borderBottom));
  Style unsetBorderLeft() => _copyWith(props: _props.unset(PropKey.borderLeft));
  Style unsetBorderForeground() => _copyWith(
      props: _props
          .unset(PropKey.borderForeground)
          .unset(PropKey.borderTopForeground)
          .unset(PropKey.borderRightForeground)
          .unset(PropKey.borderBottomForeground)
          .unset(PropKey.borderLeftForeground));
  Style unsetBorderBackground() => _copyWith(
      props: _props
          .unset(PropKey.borderBackground)
          .unset(PropKey.borderTopBackground)
          .unset(PropKey.borderRightBackground)
          .unset(PropKey.borderBottomBackground)
          .unset(PropKey.borderLeftBackground));
  Style unsetBorderTopForeground() =>
      _copyWith(props: _props.unset(PropKey.borderTopForeground));
  Style unsetBorderRightForeground() =>
      _copyWith(props: _props.unset(PropKey.borderRightForeground));
  Style unsetBorderBottomForeground() =>
      _copyWith(props: _props.unset(PropKey.borderBottomForeground));
  Style unsetBorderLeftForeground() =>
      _copyWith(props: _props.unset(PropKey.borderLeftForeground));
  Style unsetBorderTopBackground() =>
      _copyWith(props: _props.unset(PropKey.borderTopBackground));
  Style unsetBorderRightBackground() =>
      _copyWith(props: _props.unset(PropKey.borderRightBackground));
  Style unsetBorderBottomBackground() =>
      _copyWith(props: _props.unset(PropKey.borderBottomBackground));
  Style unsetBorderLeftBackground() =>
      _copyWith(props: _props.unset(PropKey.borderLeftBackground));
  Style unsetBorderForegroundBlend() =>
      _copyWith(props: _props.unset(PropKey.borderForegroundBlend));
  Style unsetBorderForegroundBlendOffset() =>
      _copyWith(props: _props.unset(PropKey.borderForegroundBlendOffset));
  Style unsetInline() => _copyWith(props: _props.unset(PropKey.inline));
  Style unsetHyperlink() => _copyWith(
      props: _props.unset(PropKey.hyperlink).unset(PropKey.hyperlinkParams));
  Style unsetTransform() => _copyWith(props: _props.unset(PropKey.transform));
  Style unsetTabWidth() => _copyWith(props: _props.unset(PropKey.tabWidth));
  Style unsetColorWhitespace() =>
      _copyWith(props: _props.unset(PropKey.colorWhitespace));
  Style unsetUnderlineSpaces() =>
      _copyWith(props: _props.unset(PropKey.underlineSpaces));
  Style unsetStrikethroughSpaces() =>
      _copyWith(props: _props.unset(PropKey.strikethroughSpaces));
  Style unsetMarginBackground() =>
      _copyWith(props: _props.unset(PropKey.marginBackground));
  Style unsetPaddingChar() =>
      _copyWith(props: _props.unset(PropKey.paddingChar));
  Style unsetMarginChar() => _copyWith(props: _props.unset(PropKey.marginChar));
  Style unsetUnderlineColor() =>
      _copyWith(props: _props.unset(PropKey.underlineColor));

  // ─── Inherit ───

  /// Copies properties from [other] that are not set on this Style.
  /// Margins and padding are NOT inherited per Lip Gloss v2 semantics.
  Style inherit(Style other) {
    var s = this;

    // Formatting
    if (!_props.has(PropKey.bold) && other._props.has(PropKey.bold)) {
      s = s.bold(other._bold);
    }
    if (!_props.has(PropKey.italic) && other._props.has(PropKey.italic)) {
      s = s.italic(other._italic);
    }
    if (!_props.has(PropKey.faint) && other._props.has(PropKey.faint)) {
      s = s.faint(other._faint);
    }
    if (!_props.has(PropKey.blink) && other._props.has(PropKey.blink)) {
      s = s.blink(other._blink);
    }
    if (!_props.has(PropKey.reverse) && other._props.has(PropKey.reverse)) {
      s = s.reverse(other._reverse);
    }
    if (!_props.has(PropKey.strikethrough) &&
        other._props.has(PropKey.strikethrough)) {
      s = s.strikethrough(other._strikethrough);
    }
    if (!_props.has(PropKey.underlineStyle) &&
        other._props.has(PropKey.underlineStyle)) {
      s = s.underline(other._underlineStyle);
    }
    if (!_props.has(PropKey.foreground) &&
        other._props.has(PropKey.foreground)) {
      s = s.foreground(other._foreground);
    }
    if (!_props.has(PropKey.background) &&
        other._props.has(PropKey.background)) {
      s = s.background(other._background);
      // Propagate background to margin background if neither has it set
      if (!_props.has(PropKey.marginBackground) &&
          !other._props.has(PropKey.marginBackground)) {
        s = s.marginBackground(other._background);
      }
    }
    if (!_props.has(PropKey.underlineColor) &&
        other._props.has(PropKey.underlineColor)) {
      s = s.underlineColor(other._underlineColor);
    }

    // Inline, tab width
    if (!_props.has(PropKey.inline) && other._props.has(PropKey.inline)) {
      s = s.inline(other._inline);
    }
    if (!_props.has(PropKey.tabWidth) && other._props.has(PropKey.tabWidth)) {
      s = s.tabWidth(other._tabWidth);
    }

    // Underline/strikethrough spaces
    if (!_props.has(PropKey.underlineSpaces) &&
        other._props.has(PropKey.underlineSpaces)) {
      s = s.underlineSpaces(other._underlineSpaces);
    }
    if (!_props.has(PropKey.strikethroughSpaces) &&
        other._props.has(PropKey.strikethroughSpaces)) {
      s = s.strikethroughSpaces(other._strikethroughSpaces);
    }
    if (!_props.has(PropKey.colorWhitespace) &&
        other._props.has(PropKey.colorWhitespace)) {
      s = s.colorWhitespace(other._colorWhitespace);
    }

    return s;
  }

  // ─── Render ───

  /// Render text with this style applied.
  /// Accepts a single string or multiple strings joined with spaces per Go semantics.
  String render([Object? textOrStrs]) {
    if (textOrStrs == null) {
      return _renderPipeline(_value ?? '');
    }
    if (textOrStrs is List<String>) {
      final allStrs = _value != null ? [_value, ...textOrStrs] : textOrStrs;
      return _renderPipeline(allStrs.join(' '));
    }
    final text = textOrStrs.toString();
    final v = _value;
    final str = v != null ? (text.isEmpty ? v : '$v $text') : text;
    return _renderPipeline(str);
  }

  /// Internal border+padding size (for wrapping/alignment calculations).
  int get _horizontalBorderPaddingSize {
    return getPaddingLeft +
        getPaddingRight +
        getBorderLeftSize +
        getBorderRightSize;
  }

  String _renderPipeline(String s) {
    var str = s;

    // 1. Apply transform function
    if (_props.has(PropKey.transform) && _transform != null) {
      str = _transform(str);
    }

    // 2. Tab conversion
    final tw = getTabWidth;
    if (tw >= 0) {
      str = _convertTabs(str, tw);
    }

    // 3. Strip carriage returns
    str = str.replaceAll('\r\n', '\n');

    // 4. Inline mode: strip newlines
    if (getInline) {
      str = str.replaceAll('\n', '');
    }

    // 5. Word wrap if width is set (skip in inline mode)
    final w = getWidth;
    if (!getInline && w > 0) {
      final wrapAt = w - _horizontalBorderPaddingSize;
      if (wrapAt > 0) {
        str = wordWrap(str, wrapAt);
      }
    }

    // 6. Apply ANSI text styling
    str = _applyTextStyle(str);

    // 7. Apply padding (skip in inline mode)
    if (!getInline) {
      str = _applyPadding(str);
    }

    // 8. Apply horizontal alignment (BEFORE vertical, matching Go order)
    final numLines = '\n'.allMatches(str).length;
    if (_props.has(PropKey.alignHorizontal) || numLines > 0 || w > 0) {
      str = _applyHorizontalAlignment(str);
    }

    // 9. Apply height constraint + vertical alignment
    if (_props.has(PropKey.height) && _height > 0) {
      str = _applyHeight(str);
    }

    // 10. Apply border (skip in inline mode)
    if (!getInline) {
      str = _applyBorder(str);
    }

    // 11. Apply margin (skip in inline mode)
    if (!getInline) {
      str = _applyMargin(str);
    }

    // 12. Apply maxWidth truncation
    if (_props.has(PropKey.maxWidth) && _maxWidth > 0) {
      str = _applyMaxWidth(str, _maxWidth);
    }

    // 13. Apply maxHeight truncation
    if (_props.has(PropKey.maxHeight) && _maxHeight > 0) {
      str = _applyMaxHeight(str, _maxHeight);
    }

    return str;
  }

  String _convertTabs(String s, int tw) {
    if (tw == 0) return s.replaceAll('\t', '');
    if (tw < 0) return s; // noTabConversion
    return s.replaceAll('\t', ' ' * tw);
  }

  String _applyTextStyle(String s) {
    // Build main text style
    final te = AnsiStyle();
    if (getBold) te.setBold();
    if (getItalic) te.setItalic();
    if (getFaint) te.setFaint();
    if (getBlink) te.setBlink();
    if (getReverse) te.setReverse();
    if (getStrikethrough) te.setStrikethrough();

    final us = getUnderlineStyle;
    if (us != UnderlineStyle.none) {
      te.setUnderline(us);
    }

    final uc = getUnderlineColor;
    if (uc is! NoColor) {
      te.setUnderlineColor(uc);
    }

    final fg = getForeground;
    if (fg is! NoColor) {
      te.setForeground(fg);
    }

    final bg = getBackground;
    if (bg is! NoColor) {
      te.setBackground(bg);
    }

    // Determine if we need separate space styling
    final underlineOn = us != UnderlineStyle.none;
    final strikethroughOn = getStrikethrough;
    final useSpaceStyler = (underlineOn && !getUnderlineSpaces) ||
        (strikethroughOn && !getStrikethroughSpaces) ||
        getUnderlineSpaces ||
        getStrikethroughSpaces;

    // Apply hyperlink if set
    final link = getHyperlink;
    final params = getHyperlinkParams;

    if (!te.hasStyle && (link == null || link.isEmpty)) return s;

    // Build space style: Go's teSpace only carries fg/bg/underlineColor
    // plus conditional underline/strikethrough. It does NOT inherit
    // bold/italic/faint/blink/reverse from the main text style.
    AnsiStyle? teSpace;
    if (useSpaceStyler) {
      teSpace = AnsiStyle();
      if (fg is! NoColor) teSpace.setForeground(fg);
      if (bg is! NoColor) teSpace.setBackground(bg);
      if (uc is! NoColor) teSpace.setUnderlineColor(uc);
      // Conditionally apply decorations to spaces
      if (getUnderlineSpaces && underlineOn) teSpace.setUnderline(us);
      if (getStrikethroughSpaces && strikethroughOn) teSpace.setStrikethrough();
    }

    // Apply style to each line to handle multi-line correctly
    final lines = s.split('\n');
    final buf = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.isNotEmpty) {
        if (te.hasStyle) {
          if (useSpaceStyler) {
            line = _styleWithSpaceStyler(line, te, teSpace!);
          } else {
            line = te.styled(line);
          }
        }
        if (link != null && link.isNotEmpty) {
          line = '${hl.setHyperlink(link, params)}$line${hl.resetHyperlink()}';
        }
      }
      buf.write(line);
      if (i < lines.length - 1) buf.write('\n');
    }

    return buf.toString();
  }

  /// Style text with separate styles for spaces vs non-spaces.
  String _styleWithSpaceStyler(
      String line, AnsiStyle teText, AnsiStyle teSpace) {
    final buf = StringBuffer();
    final textOpen = teText.openSequence;
    final spaceOpen = teSpace.openSequence;
    var inText = false;
    var inSpace = false;

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == ' ' || ch == '\t') {
        if (inText) {
          buf.write(resetSequence);
          inText = false;
        }
        if (!inSpace) {
          buf.write(spaceOpen);
          inSpace = true;
        }
        buf.write(ch);
      } else {
        if (inSpace) {
          buf.write(resetSequence);
          inSpace = false;
        }
        if (!inText) {
          buf.write(textOpen);
          inText = true;
        }
        buf.write(ch);
      }
    }

    if (inText || inSpace) {
      buf.write(resetSequence);
    }

    return buf.toString();
  }

  String _applyPadding(String s) {
    final pt = getPaddingTop;
    final pr = getPaddingRight;
    final pb = getPaddingBottom;
    final pl = getPaddingLeft;

    if (pt == 0 && pr == 0 && pb == 0 && pl == 0) return s;

    final lines = s.split('\n');

    // Find max width
    var maxW = 0;
    for (final line in lines) {
      final w = stringWidth(line);
      if (w > maxW) maxW = w;
    }

    final bgStyle = _buildBgStyle();

    // Build whitespace style for padding fill
    final wsStyle = _buildWhitespaceStyle();

    final buf = StringBuffer();

    // Top padding
    if (pt > 0) {
      final emptyLine =
          _padLine('', maxW, pl, pr, bgStyle, wsStyle, getPaddingChar);
      for (var i = 0; i < pt; i++) {
        buf.write(emptyLine);
        buf.write('\n');
      }
    }

    // Content lines with left/right padding
    for (var i = 0; i < lines.length; i++) {
      buf.write(
          _padLine(lines[i], maxW, pl, pr, bgStyle, wsStyle, getPaddingChar));
      if (i < lines.length - 1) buf.write('\n');
    }

    // Bottom padding
    if (pb > 0) {
      final emptyLine =
          _padLine('', maxW, pl, pr, bgStyle, wsStyle, getPaddingChar);
      for (var i = 0; i < pb; i++) {
        buf.write('\n');
        buf.write(emptyLine);
      }
    }

    return buf.toString();
  }

  String _padLine(String line, int contentWidth, int leftPad, int rightPad,
      AnsiStyle? bgStyle, AnsiStyle? wsStyle, String padChar) {
    final lineWidth = stringWidth(line);
    final rightFill = contentWidth - lineWidth + rightPad;

    final left = renderWhitespace(leftPad, padChar);
    final right = renderWhitespace(rightFill, padChar);

    final effectiveStyle = wsStyle ?? bgStyle;
    if (effectiveStyle != null && effectiveStyle.hasStyle) {
      return '${effectiveStyle.styled(left)}$line${effectiveStyle.styled(right)}';
    }
    return '$left$line$right';
  }

  AnsiStyle? _buildBgStyle() {
    final bg = getBackground;
    if (bg is NoColor) return null;
    return AnsiStyle()..setBackground(bg);
  }

  /// Build whitespace style for padding/alignment fill.
  /// Go's teWhitespace carries bg, and when reverse is active, also fg + reverse.
  AnsiStyle? _buildWhitespaceStyle() {
    final bg = getBackground;
    final fg = getForeground;
    final shouldStyle = getColorWhitespace || getReverse;
    if (!shouldStyle && bg is NoColor) return null;

    final ws = AnsiStyle();
    if (bg is! NoColor) ws.setBackground(bg);
    if (getReverse) {
      ws.setReverse();
      if (fg is! NoColor) ws.setForeground(fg);
    }
    return ws.hasStyle ? ws : null;
  }

  String _applyHeight(String s) {
    var targetHeight = getHeight;
    // Subtract border size from target height
    targetHeight -= getBorderTopSize;
    targetHeight -= getBorderBottomSize;
    if (targetHeight <= 0) return s;

    final lines = s.split('\n');
    // Height is minimum height, not a crop. If content is taller, return as-is.
    if (lines.length >= targetHeight) return s;

    final vAlign = getAlignVertical;

    // Build whitespace style for vertical fill
    String? wsOpen;
    String? wsClose;
    if (getColorWhitespace || getReverse) {
      final ws = _buildWhitespaceStyle();
      if (ws != null && ws.hasStyle) {
        wsOpen = ws.openSequence;
        wsClose = resetSequence;
      }
    }

    return alignTextVertical(s, vAlign, targetHeight, wsOpen, wsClose);
  }

  String _applyHorizontalAlignment(String s) {
    final w = getWidth;

    // Build whitespace style for alignment fill
    String? wsOpen;
    String? wsClose;
    if (getColorWhitespace || getReverse) {
      final ws = _buildWhitespaceStyle();
      if (ws != null && ws.hasStyle) {
        wsOpen = ws.openSequence;
        wsClose = resetSequence;
      }
    }

    if (w <= 0) {
      // Use natural width
      final lines = s.split('\n');
      var maxW = 0;
      for (final line in lines) {
        final lw = stringWidth(line);
        if (lw > maxW) maxW = lw;
      }
      if (maxW == 0) return s;
      return alignTextHorizontal(s, getAlignHorizontal, maxW, wsOpen, wsClose);
    }

    // Width only has borders subtracted (padding was already applied)
    var alignWidth = w;
    alignWidth -= getBorderLeftSize;
    alignWidth -= getBorderRightSize;
    if (alignWidth <= 0) return s;
    return alignTextHorizontal(
        s, getAlignHorizontal, alignWidth, wsOpen, wsClose);
  }

  String _applyBorder(String s) {
    final b = getBorderStyle;
    var hasTop = getBorderTop;
    var hasRight = getBorderRight;
    var hasBottom = getBorderBottom;
    var hasLeft = getBorderLeft;

    // Auto-enable all sides when border style is set but no side flags
    if (_isBorderStyleSetWithoutSides) {
      hasTop = true;
      hasRight = true;
      hasBottom = true;
      hasLeft = true;
    }

    if (!hasTop && !hasRight && !hasBottom && !hasLeft) return s;

    // Fill empty corners with spaces
    var topLeftChar = b.topLeft;
    var topRightChar = b.topRight;
    var bottomLeftChar = b.bottomLeft;
    var bottomRightChar = b.bottomRight;
    if (hasTop && hasLeft && topLeftChar.isEmpty) topLeftChar = ' ';
    if (hasTop && hasRight && topRightChar.isEmpty) topRightChar = ' ';
    if (hasBottom && hasLeft && bottomLeftChar.isEmpty) bottomLeftChar = ' ';
    if (hasBottom && hasRight && bottomRightChar.isEmpty) bottomRightChar = ' ';

    final lines = s.split('\n');
    var contentWidth = 0;
    for (final line in lines) {
      final w = stringWidth(line);
      if (w > contentWidth) contentWidth = w;
    }

    final leftW = hasLeft ? b.getLeftSize() : 0;
    final rightW = hasRight ? b.getRightSize() : 0;
    final totalWidth = contentWidth + leftW + rightW;

    // Check for border gradient blending
    final blendColors = getBorderForegroundBlend;
    final useBlend = blendColors != null && blendColors.isNotEmpty;

    // Gradient arrays per side (null if no blending)
    List<LipglossColor>? topGradient;
    List<LipglossColor>? rightGradient;
    List<LipglossColor>? bottomGradient;
    List<LipglossColor>? leftGradient;

    if (useBlend) {
      // Go's perimeter formula: (contentWidth + contentHeight + 2) * 2
      // Segments: top = contentWidth+2, right = contentHeight,
      //           bottom = contentWidth+2 (reversed), left = contentHeight (reversed)
      final h = lines.length;
      final topSeg = contentWidth + 2;
      final rightSeg = h;
      final bottomSeg = contentWidth + 2;
      final leftSeg = h;
      final totalPerimeter = topSeg + rightSeg + bottomSeg + leftSeg;
      if (totalPerimeter > 0) {
        var gradient = blend1D(totalPerimeter, blendColors);
        // Rotate by offset
        final offset = getBorderForegroundBlendOffset % gradient.length;
        if (offset != 0) {
          gradient = [
            ...gradient.sublist(offset),
            ...gradient.sublist(0, offset)
          ];
        }
        // Slice into segments: top, right, bottom (reversed), left (reversed)
        var idx = 0;
        topGradient = gradient.sublist(idx, idx + topSeg);
        idx += topSeg;
        rightGradient = gradient.sublist(idx, idx + rightSeg);
        idx += rightSeg;
        bottomGradient =
            gradient.sublist(idx, idx + bottomSeg).reversed.toList();
        idx += bottomSeg;
        leftGradient = gradient.sublist(idx, idx + leftSeg).reversed.toList();
      }
    }

    // Per-side style functions (used when NOT blending)
    String Function(String) styleBorderTop = (s) => s;
    String Function(String) styleBorderRight = (s) => s;
    String Function(String) styleBorderBottom = (s) => s;
    String Function(String) styleBorderLeft = (s) => s;

    if (!useBlend) {
      void buildSideStyler(LipglossColor fg, LipglossColor bg,
          void Function(String Function(String)) setter) {
        final sgr = AnsiStyle();
        if (fg is! NoColor) sgr.setForeground(fg);
        if (bg is! NoColor) sgr.setBackground(bg);
        if (sgr.hasStyle) {
          setter((str) => str.isEmpty ? str : sgr.styled(str));
        }
      }

      buildSideStyler(getBorderTopForeground, getBorderTopBackground,
          (fn) => styleBorderTop = fn);
      buildSideStyler(getBorderRightForeground, getBorderRightBackground,
          (fn) => styleBorderRight = fn);
      buildSideStyler(getBorderBottomForeground, getBorderBottomBackground,
          (fn) => styleBorderBottom = fn);
      buildSideStyler(getBorderLeftForeground, getBorderLeftBackground,
          (fn) => styleBorderLeft = fn);
    }

    /// Style a single border character with a gradient foreground color,
    /// preserving the per-side background color.
    String styleCharGradient(
        String ch, LipglossColor fgColor, LipglossColor bgColor) {
      if (ch.isEmpty) return ch;
      final sgr = AnsiStyle()..setForeground(fgColor);
      if (bgColor is! NoColor) sgr.setBackground(bgColor);
      return sgr.styled(ch);
    }

    /// Style each character of an edge string with gradient colors.
    String styleEdgeGradient(
        String edge, List<LipglossColor> gradient, LipglossColor bg) {
      final buf = StringBuffer();
      var gi = 0;
      for (var i = 0; i < edge.length && gi < gradient.length; i++) {
        buf.write(styleCharGradient(edge[i], gradient[gi], bg));
        gi++;
      }
      return buf.toString();
    }

    final buf = StringBuffer();

    // Top border
    if (hasTop) {
      final topEdge = renderHorizontalEdge(
        hasLeft ? topLeftChar : '',
        b.top,
        hasRight ? topRightChar : '',
        totalWidth,
      );
      if (topGradient != null) {
        buf.write(
            styleEdgeGradient(topEdge, topGradient, getBorderTopBackground));
      } else {
        buf.write(styleBorderTop(topEdge));
      }
      buf.write('\n');
    }

    // Content lines with side borders
    for (var i = 0; i < lines.length; i++) {
      if (hasLeft) {
        if (leftGradient != null && i < leftGradient.length) {
          buf.write(styleCharGradient(
              b.left, leftGradient[i], getBorderLeftBackground));
        } else {
          buf.write(styleBorderLeft(b.left));
        }
      }

      final line = lines[i];
      final lineWidth = stringWidth(line);
      buf.write(line);

      // Pad to content width
      final padNeeded = contentWidth - lineWidth;
      if (padNeeded > 0) buf.write(' ' * padNeeded);

      if (hasRight) {
        if (rightGradient != null && i < rightGradient.length) {
          buf.write(styleCharGradient(
              b.right, rightGradient[i], getBorderRightBackground));
        } else {
          buf.write(styleBorderRight(b.right));
        }
      }
      if (i < lines.length - 1 || hasBottom) buf.write('\n');
    }

    // Bottom border
    if (hasBottom) {
      final bottomEdge = renderHorizontalEdge(
        hasLeft ? bottomLeftChar : '',
        b.bottom,
        hasRight ? bottomRightChar : '',
        totalWidth,
      );
      if (bottomGradient != null) {
        buf.write(styleEdgeGradient(
            bottomEdge, bottomGradient, getBorderBottomBackground));
      } else {
        buf.write(styleBorderBottom(bottomEdge));
      }
    }

    return buf.toString();
  }

  String _applyMargin(String s) {
    final mt = getMarginTop;
    final mr = getMarginRight;
    final mb = getMarginBottom;
    final ml = getMarginLeft;

    if (mt == 0 && mr == 0 && mb == 0 && ml == 0) return s;

    final marginBg = getMarginBackground;
    final hasMarginBg = marginBg is! NoColor;
    final marginSgr =
        hasMarginBg ? (AnsiStyle()..setBackground(marginBg)) : null;

    String marginStr(int width) {
      final ws = renderWhitespace(width, getMarginChar);
      if (marginSgr != null) return marginSgr.styled(ws);
      return ws;
    }

    final lines = s.split('\n');

    // Find max width for empty margin lines
    var maxW = 0;
    for (final line in lines) {
      final w = stringWidth(line);
      if (w > maxW) maxW = w;
    }
    final totalWidth = ml + maxW + mr;

    final buf = StringBuffer();

    // Top margin
    for (var i = 0; i < mt; i++) {
      if (hasMarginBg) {
        buf.write(marginStr(totalWidth));
      }
      buf.write('\n');
    }

    // Content with side margins
    for (var i = 0; i < lines.length; i++) {
      if (ml > 0) buf.write(marginStr(ml));
      buf.write(lines[i]);
      if (mr > 0) {
        final lineW = stringWidth(lines[i]);
        final rightPad = maxW - lineW + mr;
        buf.write(marginStr(rightPad));
      }
      if (i < lines.length - 1) buf.write('\n');
    }

    // Bottom margin
    for (var i = 0; i < mb; i++) {
      buf.write('\n');
      if (hasMarginBg) {
        buf.write(marginStr(totalWidth));
      }
    }

    return buf.toString();
  }

  String _applyMaxWidth(String s, int maxW) {
    final lines = s.split('\n');
    final buf = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (stringWidth(line) > maxW) {
        buf.write(trunc.truncate(line, maxW));
      } else {
        buf.write(line);
      }
      if (i < lines.length - 1) buf.write('\n');
    }
    return buf.toString();
  }

  String _applyMaxHeight(String s, int maxH) {
    final lines = s.split('\n');
    if (lines.length <= maxH) return s;
    return lines.take(maxH).join('\n');
  }

  @override
  String toString() => _value != null ? render() : '';

  // ─── Private ───

  Style _copyWith({
    Props? props,
    bool? bold,
    bool? italic,
    bool? faint,
    bool? blink,
    bool? reverse,
    bool? strikethrough,
    UnderlineStyle? underlineStyle,
    LipglossColor? underlineColor,
    LipglossColor? foreground,
    LipglossColor? background,
    LipglossColor? marginBackground,
    int? width,
    int? height,
    int? maxWidth,
    int? maxHeight,
    double? alignHorizontal,
    double? alignVertical,
    int? paddingTop,
    int? paddingRight,
    int? paddingBottom,
    int? paddingLeft,
    int? marginTop,
    int? marginRight,
    int? marginBottom,
    int? marginLeft,
    String? paddingChar,
    String? marginChar,
    Border? borderStyle,
    bool? borderTop,
    bool? borderRight,
    bool? borderBottom,
    bool? borderLeft,
    LipglossColor? borderForeground,
    LipglossColor? borderBackground,
    List<LipglossColor>? borderForegroundBlend,
    LipglossColor? borderTopForeground,
    LipglossColor? borderRightForeground,
    LipglossColor? borderBottomForeground,
    LipglossColor? borderLeftForeground,
    LipglossColor? borderTopBackground,
    LipglossColor? borderRightBackground,
    LipglossColor? borderBottomBackground,
    LipglossColor? borderLeftBackground,
    int? borderForegroundBlendOffset,
    bool? inline,
    int? tabWidth,
    bool? underlineSpaces,
    bool? strikethroughSpaces,
    bool? colorWhitespace,
    String Function(String)? transform,
    String? hyperlink,
    Map<String, String>? hyperlinkParams,
    String? value,
    bool clearValue = false,
  }) {
    return Style._(
      props: props ?? _props,
      bold: bold ?? _bold,
      italic: italic ?? _italic,
      faint: faint ?? _faint,
      blink: blink ?? _blink,
      reverse: reverse ?? _reverse,
      strikethrough: strikethrough ?? _strikethrough,
      underlineStyle: underlineStyle ?? _underlineStyle,
      underlineColor: underlineColor ?? _underlineColor,
      foreground: foreground ?? _foreground,
      background: background ?? _background,
      marginBackground: marginBackground ?? _marginBackground,
      width: width ?? _width,
      height: height ?? _height,
      maxWidth: maxWidth ?? _maxWidth,
      maxHeight: maxHeight ?? _maxHeight,
      alignHorizontal: alignHorizontal ?? _alignHorizontal,
      alignVertical: alignVertical ?? _alignVertical,
      paddingTop: paddingTop ?? _paddingTop,
      paddingRight: paddingRight ?? _paddingRight,
      paddingBottom: paddingBottom ?? _paddingBottom,
      paddingLeft: paddingLeft ?? _paddingLeft,
      marginTop: marginTop ?? _marginTop,
      marginRight: marginRight ?? _marginRight,
      marginBottom: marginBottom ?? _marginBottom,
      marginLeft: marginLeft ?? _marginLeft,
      paddingChar: paddingChar ?? _paddingChar,
      marginChar: marginChar ?? _marginChar,
      borderStyle: borderStyle ?? _borderStyle,
      borderTop: borderTop ?? _borderTop,
      borderRight: borderRight ?? _borderRight,
      borderBottom: borderBottom ?? _borderBottom,
      borderLeft: borderLeft ?? _borderLeft,
      borderForeground: borderForeground ?? _borderForeground,
      borderBackground: borderBackground ?? _borderBackground,
      borderForegroundBlend: borderForegroundBlend ?? _borderForegroundBlend,
      borderTopForeground: borderTopForeground ?? _borderTopForeground,
      borderRightForeground: borderRightForeground ?? _borderRightForeground,
      borderBottomForeground: borderBottomForeground ?? _borderBottomForeground,
      borderLeftForeground: borderLeftForeground ?? _borderLeftForeground,
      borderTopBackground: borderTopBackground ?? _borderTopBackground,
      borderRightBackground: borderRightBackground ?? _borderRightBackground,
      borderBottomBackground: borderBottomBackground ?? _borderBottomBackground,
      borderLeftBackground: borderLeftBackground ?? _borderLeftBackground,
      borderForegroundBlendOffset:
          borderForegroundBlendOffset ?? _borderForegroundBlendOffset,
      inline: inline ?? _inline,
      tabWidth: tabWidth ?? _tabWidth,
      underlineSpaces: underlineSpaces ?? _underlineSpaces,
      strikethroughSpaces: strikethroughSpaces ?? _strikethroughSpaces,
      colorWhitespace: colorWhitespace ?? _colorWhitespace,
      transform: transform ?? _transform,
      hyperlink: hyperlink ?? _hyperlink,
      hyperlinkParams: hyperlinkParams ?? _hyperlinkParams,
      value: clearValue ? null : (value ?? _value),
    );
  }

  /// CSS-style shorthand helper for integer values.
  static ({int top, int right, int bottom, int left}) _whichSidesInt(
    int top, [
    int? right,
    int? bottom,
    int? left,
  ]) {
    if (right == null && bottom == null && left == null) {
      return (top: top, right: top, bottom: top, left: top);
    }
    if (bottom == null && left == null) {
      final r = right!;
      return (top: top, right: r, bottom: top, left: r);
    }
    if (left == null) {
      final r = right!;
      return (top: top, right: r, bottom: bottom!, left: r);
    }
    return (top: top, right: right!, bottom: bottom!, left: left);
  }

  /// CSS-style shorthand helper for boolean values.
  static ({bool top, bool right, bool bottom, bool left}) _whichSidesBool(
    bool top, [
    bool? right,
    bool? bottom,
    bool? left,
  ]) {
    if (right == null && bottom == null && left == null) {
      return (top: top, right: top, bottom: top, left: top);
    }
    if (bottom == null && left == null) {
      final r = right!;
      return (top: top, right: r, bottom: top, left: r);
    }
    if (left == null) {
      final r = right!;
      return (top: top, right: r, bottom: bottom!, left: r);
    }
    return (top: top, right: right!, bottom: bottom!, left: left);
  }

  /// CSS-style shorthand helper for color values.
  static ({
    LipglossColor top,
    LipglossColor right,
    LipglossColor bottom,
    LipglossColor left
  }) _whichSidesColor(
    LipglossColor top, [
    LipglossColor? right,
    LipglossColor? bottom,
    LipglossColor? left,
  ]) {
    if (right == null && bottom == null && left == null) {
      return (top: top, right: top, bottom: top, left: top);
    }
    if (bottom == null && left == null) {
      final r = right!;
      return (top: top, right: r, bottom: top, left: r);
    }
    if (left == null) {
      final r = right!;
      return (top: top, right: r, bottom: bottom!, left: r);
    }
    return (top: top, right: right!, bottom: bottom!, left: left);
  }
}

// lipPrint/lipPrintln are in writer.dart with color downsampling support.
