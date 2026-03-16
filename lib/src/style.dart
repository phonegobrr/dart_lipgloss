// Ported from charmbracelet/lipgloss style.go, set.go, get.go, unset.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'package:meta/meta.dart';

import 'align.dart';
import 'ansi/hyperlink.dart' as hl;
import 'ansi/sgr.dart';
import 'ansi/truncate.dart' as trunc;
import 'ansi/width.dart';
import 'border.dart';
import 'color.dart';
import 'props.dart';
import 'whitespace.dart';
import 'wrap.dart';

/// Tab conversion constant. Set tab width to this to disable tab conversion.
const noTabConversion = -1;

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

  // Behavior
  final bool _inline;
  final int _tabWidth;
  final bool _underlineSpaces;
  final bool _strikethroughSpaces;
  final bool _colorWhitespace;
  final String Function(String)? _transform;
  final String? _hyperlink;

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
    bool inline = false,
    int tabWidth = 4,
    bool underlineSpaces = false,
    bool strikethroughSpaces = false,
    bool colorWhitespace = true,
    String Function(String)? transform,
    String? hyperlink,
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
        _inline = inline,
        _tabWidth = tabWidth,
        _underlineSpaces = underlineSpaces,
        _strikethroughSpaces = strikethroughSpaces,
        _colorWhitespace = colorWhitespace,
        _transform = transform,
        _hyperlink = hyperlink,
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

  Style border(Border b, [bool? top, bool? right, bool? bottom, bool? left]) {
    var p = _props.set(PropKey.borderStyle);
    var bt = top ?? true;
    var br = right ?? true;
    var bb = bottom ?? true;
    var bl = left ?? true;

    // If only top is specified, use it for all sides
    if (top != null && right == null && bottom == null && left == null) {
      bt = top;
      br = top;
      bb = top;
      bl = top;
    }

    p = p
        .set(PropKey.borderTop)
        .set(PropKey.borderRight)
        .set(PropKey.borderBottom)
        .set(PropKey.borderLeft);

    return _copyWith(
      props: p,
      borderStyle: b,
      borderTop: bt,
      borderRight: br,
      borderBottom: bb,
      borderLeft: bl,
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

  Style borderForeground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderForeground),
        borderForeground: c,
      );

  Style borderBackground(LipglossColor c) => _copyWith(
        props: _props.set(PropKey.borderBackground),
        borderBackground: c,
      );

  Style borderForegroundBlend(List<LipglossColor> colors) => _copyWith(
        props: _props.set(PropKey.borderForegroundBlend),
        borderForegroundBlend: colors,
      );

  Style align(double horizontal, [double? vertical]) => _copyWith(
        props: _props.set(PropKey.alignHorizontal).set(PropKey.alignVertical),
        alignHorizontal: horizontal,
        alignVertical: vertical ?? horizontal,
      );

  Style alignHorizontal(double v) => _copyWith(
        props: _props.set(PropKey.alignHorizontal),
        alignHorizontal: v,
      );

  Style alignVertical(double v) => _copyWith(
        props: _props.set(PropKey.alignVertical),
        alignVertical: v,
      );

  Style inlineMode([bool v = true]) => _copyWith(
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

  Style setHyperlink(String url) => _copyWith(
        props: _props.set(PropKey.hyperlink),
        hyperlink: url,
      );

  Style paddingChar(String c) => _copyWith(
        props: _props.set(PropKey.paddingChar),
        paddingChar: c,
      );

  Style marginChar(String c) => _copyWith(
        props: _props.set(PropKey.marginChar),
        marginChar: c,
      );

  Style setString(String s) => _copyWith(value: s);

  // ─── Getters ───

  bool get getBold => _props.has(PropKey.bold) ? _bold : false;
  bool get getItalic => _props.has(PropKey.italic) ? _italic : false;
  bool get getFaint => _props.has(PropKey.faint) ? _faint : false;
  bool get getBlink => _props.has(PropKey.blink) ? _blink : false;
  bool get getReverse => _props.has(PropKey.reverse) ? _reverse : false;
  bool get getStrikethrough =>
      _props.has(PropKey.strikethrough) ? _strikethrough : false;
  UnderlineStyle get getUnderlineStyle =>
      _props.has(PropKey.underlineStyle) ? _underlineStyle : UnderlineStyle.none;
  LipglossColor get getUnderlineColor =>
      _props.has(PropKey.underlineColor) ? _underlineColor : const NoColor();
  LipglossColor get getForeground =>
      _props.has(PropKey.foreground) ? _foreground : const NoColor();
  LipglossColor get getBackground =>
      _props.has(PropKey.background) ? _background : const NoColor();
  LipglossColor get getMarginBackground =>
      _props.has(PropKey.marginBackground) ? _marginBackground : const NoColor();
  int get getWidth => _props.has(PropKey.width) ? _width : 0;
  int get getHeight => _props.has(PropKey.height) ? _height : 0;
  int get getMaxWidth => _props.has(PropKey.maxWidth) ? _maxWidth : 0;
  int get getMaxHeight => _props.has(PropKey.maxHeight) ? _maxHeight : 0;
  double get getAlignHorizontal =>
      _props.has(PropKey.alignHorizontal) ? _alignHorizontal : 0.0;
  double get getAlignVertical =>
      _props.has(PropKey.alignVertical) ? _alignVertical : 0.0;
  int get getPaddingTop => _props.has(PropKey.paddingTop) ? _paddingTop : 0;
  int get getPaddingRight => _props.has(PropKey.paddingRight) ? _paddingRight : 0;
  int get getPaddingBottom =>
      _props.has(PropKey.paddingBottom) ? _paddingBottom : 0;
  int get getPaddingLeft => _props.has(PropKey.paddingLeft) ? _paddingLeft : 0;
  int get getMarginTop => _props.has(PropKey.marginTop) ? _marginTop : 0;
  int get getMarginRight => _props.has(PropKey.marginRight) ? _marginRight : 0;
  int get getMarginBottom => _props.has(PropKey.marginBottom) ? _marginBottom : 0;
  int get getMarginLeft => _props.has(PropKey.marginLeft) ? _marginLeft : 0;
  Border get getBorderStyle =>
      _props.has(PropKey.borderStyle) ? _borderStyle : noBorder;
  bool get getBorderTop => _props.has(PropKey.borderTop) ? _borderTop : false;
  bool get getBorderRight => _props.has(PropKey.borderRight) ? _borderRight : false;
  bool get getBorderBottom =>
      _props.has(PropKey.borderBottom) ? _borderBottom : false;
  bool get getBorderLeft => _props.has(PropKey.borderLeft) ? _borderLeft : false;
  LipglossColor get getBorderForeground =>
      _props.has(PropKey.borderForeground) ? _borderForeground : const NoColor();
  LipglossColor get getBorderBackground =>
      _props.has(PropKey.borderBackground) ? _borderBackground : const NoColor();
  bool get getInline => _props.has(PropKey.inline) ? _inline : false;
  int get getTabWidth => _props.has(PropKey.tabWidth) ? _tabWidth : 4;
  bool get getUnderlineSpaces =>
      _props.has(PropKey.underlineSpaces) ? _underlineSpaces : false;
  bool get getStrikethroughSpaces =>
      _props.has(PropKey.strikethroughSpaces) ? _strikethroughSpaces : false;
  bool get getColorWhitespace =>
      _props.has(PropKey.colorWhitespace) ? _colorWhitespace : true;
  String? get getHyperlink =>
      _props.has(PropKey.hyperlink) ? _hyperlink : null;
  String? get getValue => _value;

  /// Total horizontal frame size (left border + left padding + right padding + right border).
  int get getHorizontalFrameSize {
    var size = getPaddingLeft + getPaddingRight;
    final b = getBorderStyle;
    if (getBorderLeft) size += b.getLeftSize();
    if (getBorderRight) size += b.getRightSize();
    return size;
  }

  /// Total vertical frame size (top border + top padding + bottom padding + bottom border).
  int get getVerticalFrameSize {
    var size = getPaddingTop + getPaddingBottom;
    final b = getBorderStyle;
    if (getBorderTop) size += b.getTopSize();
    if (getBorderBottom) size += b.getBottomSize();
    return size;
  }

  /// Frame size as (width, height).
  (int, int) get getFrameSize =>
      (getHorizontalFrameSize, getVerticalFrameSize);

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
  Style unsetForeground() =>
      _copyWith(props: _props.unset(PropKey.foreground));
  Style unsetBackground() =>
      _copyWith(props: _props.unset(PropKey.background));
  Style unsetWidth() => _copyWith(props: _props.unset(PropKey.width));
  Style unsetHeight() => _copyWith(props: _props.unset(PropKey.height));
  Style unsetMaxWidth() => _copyWith(props: _props.unset(PropKey.maxWidth));
  Style unsetMaxHeight() => _copyWith(props: _props.unset(PropKey.maxHeight));
  Style unsetAlignHorizontal() =>
      _copyWith(props: _props.unset(PropKey.alignHorizontal));
  Style unsetAlignVertical() =>
      _copyWith(props: _props.unset(PropKey.alignVertical));
  Style unsetPaddingTop() =>
      _copyWith(props: _props.unset(PropKey.paddingTop));
  Style unsetPaddingRight() =>
      _copyWith(props: _props.unset(PropKey.paddingRight));
  Style unsetPaddingBottom() =>
      _copyWith(props: _props.unset(PropKey.paddingBottom));
  Style unsetPaddingLeft() =>
      _copyWith(props: _props.unset(PropKey.paddingLeft));
  Style unsetMarginTop() =>
      _copyWith(props: _props.unset(PropKey.marginTop));
  Style unsetMarginRight() =>
      _copyWith(props: _props.unset(PropKey.marginRight));
  Style unsetMarginBottom() =>
      _copyWith(props: _props.unset(PropKey.marginBottom));
  Style unsetMarginLeft() =>
      _copyWith(props: _props.unset(PropKey.marginLeft));
  Style unsetBorderStyle() =>
      _copyWith(props: _props.unset(PropKey.borderStyle));
  Style unsetBorderTop() =>
      _copyWith(props: _props.unset(PropKey.borderTop));
  Style unsetBorderRight() =>
      _copyWith(props: _props.unset(PropKey.borderRight));
  Style unsetBorderBottom() =>
      _copyWith(props: _props.unset(PropKey.borderBottom));
  Style unsetBorderLeft() =>
      _copyWith(props: _props.unset(PropKey.borderLeft));
  Style unsetBorderForeground() =>
      _copyWith(props: _props.unset(PropKey.borderForeground));
  Style unsetBorderBackground() =>
      _copyWith(props: _props.unset(PropKey.borderBackground));
  Style unsetInline() => _copyWith(props: _props.unset(PropKey.inline));
  Style unsetHyperlink() =>
      _copyWith(props: _props.unset(PropKey.hyperlink));

  // ─── Inherit ───

  /// Copies properties from [other] that are not set on this Style.
  /// Margins are NOT inherited per Lip Gloss semantics.
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
    }
    if (!_props.has(PropKey.underlineColor) &&
        other._props.has(PropKey.underlineColor)) {
      s = s.underlineColor(other._underlineColor);
    }

    // Layout (padding inherited, NOT margins)
    if (!_props.has(PropKey.paddingTop) &&
        other._props.has(PropKey.paddingTop)) {
      s = s.paddingTop(other._paddingTop);
    }
    if (!_props.has(PropKey.paddingRight) &&
        other._props.has(PropKey.paddingRight)) {
      s = s.paddingRight(other._paddingRight);
    }
    if (!_props.has(PropKey.paddingBottom) &&
        other._props.has(PropKey.paddingBottom)) {
      s = s.paddingBottom(other._paddingBottom);
    }
    if (!_props.has(PropKey.paddingLeft) &&
        other._props.has(PropKey.paddingLeft)) {
      s = s.paddingLeft(other._paddingLeft);
    }

    // Inline, tab width
    if (!_props.has(PropKey.inline) && other._props.has(PropKey.inline)) {
      s = s.inlineMode(other._inline);
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
  /// This is a pure function — no I/O, no terminal detection.
  String render([String text = '']) {
    // If _value is set, prepend it
    final v = _value;
    final str = v != null
        ? (text.isEmpty ? v : '$v$text')
        : text;
    return _renderPipeline(str);
  }

  String _renderPipeline(String s) {
    var str = s;

    // 1. Apply transform function
    if (_props.has(PropKey.transform) && _transform != null) {
      str = _transform(str);
    }

    // 2. Tab conversion
    if (getTabWidth >= 0) {
      str = _convertTabs(str, getTabWidth);
    }

    // 3. Strip carriage returns
    str = str.replaceAll('\r\n', '\n');

    // 4. Inline mode: strip newlines
    if (getInline) {
      str = str.replaceAll('\n', '');
    }

    // 5. Word wrap if width is set
    final w = getWidth;
    final hFrameSize = getHorizontalFrameSize;
    if (w > 0) {
      final wrapAt = w - hFrameSize;
      if (wrapAt > 0) {
        str = wordWrap(str, wrapAt);
      }
    }

    // 6. Apply ANSI text styling
    str = _applyTextStyle(str);

    // 7. Apply padding
    str = _applyPadding(str);

    // 8. Apply height constraint + vertical alignment
    if (_props.has(PropKey.height) && _height > 0) {
      str = _applyHeight(str, _height);
    }

    // 9. Apply horizontal alignment
    if (_props.has(PropKey.alignHorizontal)) {
      str = _applyHorizontalAlignment(str);
    }

    // 10. Apply border
    str = _applyBorder(str);

    // 11. Apply margin
    str = _applyMargin(str);

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
    if (tw <= 0) return s;
    return s.replaceAll('\t', ' ' * tw);
  }

  String _applyTextStyle(String s) {
    final style = AnsiStyle();
    if (getBold) style.setBold();
    if (getItalic) style.setItalic();
    if (getFaint) style.setFaint();
    if (getBlink) style.setBlink();
    if (getReverse) style.setReverse();
    if (getStrikethrough) style.setStrikethrough();

    final us = getUnderlineStyle;
    if (us != UnderlineStyle.none) {
      style.setUnderline(us);
    }

    final uc = getUnderlineColor;
    if (uc is! NoColor) {
      style.setUnderlineColor(uc);
    }

    final fg = getForeground;
    if (fg is! NoColor) {
      style.setForeground(fg);
    }

    final bg = getBackground;
    if (bg is! NoColor) {
      style.setBackground(bg);
    }

    if (!style.hasStyle) return s;

    // Apply hyperlink if set
    final link = getHyperlink;

    // Apply style to each line to handle multi-line correctly
    final lines = s.split('\n');
    final buf = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.isNotEmpty) {
        if (getUnderlineSpaces || getStrikethroughSpaces || getColorWhitespace) {
          line = style.styled(line);
        } else {
          // Style non-whitespace portions, leave whitespace unstyled
          line = _styleNonWhitespace(line, style);
        }
        if (link != null && link.isNotEmpty) {
          line = hl.hyperlink(link, line);
        }
      }
      buf.write(line);
      if (i < lines.length - 1) buf.write('\n');
    }

    return buf.toString();
  }

  String _styleNonWhitespace(String line, AnsiStyle style) {
    // Simple approach: style the whole line. Full whitespace-aware styling
    // would require walking char by char, which we simplify here.
    return style.styled(line);
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

    final buf = StringBuffer();

    // Top padding
    if (pt > 0) {
      final emptyLine = _padLine('', maxW, pl, pr, bgStyle);
      for (var i = 0; i < pt; i++) {
        buf.write(emptyLine);
        buf.write('\n');
      }
    }

    // Content lines with left/right padding
    for (var i = 0; i < lines.length; i++) {
      buf.write(_padLine(lines[i], maxW, pl, pr, bgStyle));
      if (i < lines.length - 1) buf.write('\n');
    }

    // Bottom padding
    if (pb > 0) {
      final emptyLine = _padLine('', maxW, pl, pr, bgStyle);
      for (var i = 0; i < pb; i++) {
        buf.write('\n');
        buf.write(emptyLine);
      }
    }

    return buf.toString();
  }

  String _padLine(String line, int contentWidth, int leftPad, int rightPad, AnsiStyle? bgStyle) {
    final lineWidth = stringWidth(line);
    final rightFill = contentWidth - lineWidth + rightPad;

    final left = renderWhitespace(leftPad, _paddingChar);
    final right = renderWhitespace(rightFill, _paddingChar);

    if (bgStyle != null && bgStyle.hasStyle) {
      return '${bgStyle.styled(left)}$line${bgStyle.styled(right)}';
    }
    return '$left$line$right';
  }

  AnsiStyle? _buildBgStyle() {
    final bg = getBackground;
    if (bg is NoColor) return null;
    return AnsiStyle()..setBackground(bg);
  }

  String _applyHeight(String s, int targetHeight) {
    final lines = s.split('\n');
    if (lines.length >= targetHeight) {
      return lines.take(targetHeight).join('\n');
    }

    final vAlign = getAlignVertical;
    return alignTextVertical(s, vAlign, targetHeight);
  }

  String _applyHorizontalAlignment(String s) {
    final w = getWidth;
    if (w <= 0) {
      // Use natural width
      final lines = s.split('\n');
      var maxW = 0;
      for (final line in lines) {
        final lw = stringWidth(line);
        if (lw > maxW) maxW = lw;
      }
      if (maxW == 0) return s;
      return alignTextHorizontal(s, _alignHorizontal, maxW);
    }

    final alignWidth = w - getHorizontalFrameSize;
    if (alignWidth <= 0) return s;
    return alignTextHorizontal(s, _alignHorizontal, alignWidth);
  }

  String _applyBorder(String s) {
    final b = getBorderStyle;
    final hasTop = getBorderTop;
    final hasRight = getBorderRight;
    final hasBottom = getBorderBottom;
    final hasLeft = getBorderLeft;

    if (!hasTop && !hasRight && !hasBottom && !hasLeft) return s;

    final lines = s.split('\n');
    var contentWidth = 0;
    for (final line in lines) {
      final w = stringWidth(line);
      if (w > contentWidth) contentWidth = w;
    }

    final borderFg = getBorderForeground;
    final borderBg = getBorderBackground;
    final borderSgr = AnsiStyle();
    if (borderFg is! NoColor) borderSgr.setForeground(borderFg);
    if (borderBg is! NoColor) borderSgr.setBackground(borderBg);
    final hasBorderStyle = borderSgr.hasStyle;

    String styleBorderStr(String str) {
      if (!hasBorderStyle || str.isEmpty) return str;
      return borderSgr.styled(str);
    }

    final leftW = hasLeft ? b.getLeftSize() : 0;
    final rightW = hasRight ? b.getRightSize() : 0;
    final totalWidth = contentWidth + leftW + rightW;

    final buf = StringBuffer();

    // Top border
    if (hasTop) {
      final topEdge = renderHorizontalEdge(
        hasLeft ? b.topLeft : '',
        b.top,
        hasRight ? b.topRight : '',
        totalWidth,
      );
      buf.write(styleBorderStr(topEdge));
      buf.write('\n');
    }

    // Content lines with side borders
    for (var i = 0; i < lines.length; i++) {
      if (hasLeft) buf.write(styleBorderStr(b.left));

      final line = lines[i];
      final lineWidth = stringWidth(line);
      buf.write(line);

      // Pad to content width
      final padNeeded = contentWidth - lineWidth;
      if (padNeeded > 0) buf.write(' ' * padNeeded);

      if (hasRight) buf.write(styleBorderStr(b.right));
      if (i < lines.length - 1 || hasBottom) buf.write('\n');
    }

    // Bottom border
    if (hasBottom) {
      final bottomEdge = renderHorizontalEdge(
        hasLeft ? b.bottomLeft : '',
        b.bottom,
        hasRight ? b.bottomRight : '',
        totalWidth,
      );
      buf.write(styleBorderStr(bottomEdge));
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
    final marginSgr = hasMarginBg ? (AnsiStyle()..setBackground(marginBg)) : null;

    String marginStr(int width) {
      final ws = renderWhitespace(width, _marginChar);
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
    bool? inline,
    int? tabWidth,
    bool? underlineSpaces,
    bool? strikethroughSpaces,
    bool? colorWhitespace,
    String Function(String)? transform,
    String? hyperlink,
    String? value,
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
      inline: inline ?? _inline,
      tabWidth: tabWidth ?? _tabWidth,
      underlineSpaces: underlineSpaces ?? _underlineSpaces,
      strikethroughSpaces: strikethroughSpaces ?? _strikethroughSpaces,
      colorWhitespace: colorWhitespace ?? _colorWhitespace,
      transform: transform ?? _transform,
      hyperlink: hyperlink ?? _hyperlink,
      value: value ?? _value,
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
      // 1 arg = all sides
      return (top: top, right: top, bottom: top, left: top);
    }
    if (bottom == null && left == null) {
      // 2 args = vert/horiz — right is non-null since first check failed
      final r = right!;
      return (top: top, right: r, bottom: top, left: r);
    }
    if (left == null) {
      // 3 args = top/horiz/bottom — right and bottom are non-null
      final r = right!;
      return (top: top, right: r, bottom: bottom!, left: r);
    }
    // 4 args = all four
    return (top: top, right: right!, bottom: bottom!, left: left);
  }
}

// ─── Top-level print functions ───

/// Print with style. Avoids collision with Dart built-in `print`.
void lipPrintln(Object? v) => print(v);

/// Print without trailing newline.
void lipPrint(Object? v) {
  // ignore: avoid_print
  print(v);
}
