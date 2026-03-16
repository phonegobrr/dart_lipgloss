// Ported from charmbracelet/lipgloss position.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'ansi/width.dart';
import 'style.dart';
import 'whitespace.dart';

/// Position constants.
const double posTop = 0.0;
const double posBottom = 1.0;
const double posCenter = 0.5;
const double posLeft = 0.0;
const double posRight = 1.0;

/// WhitespaceOption configures whitespace rendering in Place functions.
typedef WhitespaceOption = void Function(WhitespaceConfig);

class WhitespaceConfig {
  String chars = ' ';
  Style? style;
}

/// Set the whitespace style for Place functions.
WhitespaceOption withWhitespaceStyle(Style s) => (w) => w.style = s;

/// Set the whitespace characters for Place functions.
WhitespaceOption withWhitespaceChars(String c) => (w) => w.chars = c;

/// Place a string within a region of [width] x [height].
String place(
  int width,
  int height,
  double hPos,
  double vPos,
  String str, [
  List<WhitespaceOption> opts = const [],
]) {
  return placeVertical(
    height,
    vPos,
    placeHorizontal(width, hPos, str, opts),
    opts,
  );
}

/// Place a string horizontally within [width].
String placeHorizontal(
  int width,
  double pos,
  String str, [
  List<WhitespaceOption> opts = const [],
]) {
  final ws = WhitespaceConfig();
  for (final opt in opts) {
    opt(ws);
  }

  final lines = str.split('\n');
  final contentWidth = lines.fold<int>(0, (max, line) {
    final w = stringWidth(line);
    return w > max ? w : max;
  });

  if (contentWidth >= width) return str;

  final buf = StringBuffer();
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final lineWidth = stringWidth(line);
    final totalPad = width - lineWidth;
    final leftPad = (totalPad * pos).toInt();
    final rightPad = totalPad - leftPad;

    if (leftPad > 0) {
      final leftStr = renderWhitespace(leftPad, ws.chars);
      buf.write(ws.style != null ? ws.style!.render(leftStr) : leftStr);
    }
    buf.write(line);
    if (rightPad > 0) {
      final rightStr = renderWhitespace(rightPad, ws.chars);
      buf.write(ws.style != null ? ws.style!.render(rightStr) : rightStr);
    }

    if (i < lines.length - 1) buf.write('\n');
  }

  return buf.toString();
}

/// Place a string vertically within [height] lines.
String placeVertical(
  int height,
  double pos,
  String str, [
  List<WhitespaceOption> opts = const [],
]) {
  final ws = WhitespaceConfig();
  for (final opt in opts) {
    opt(ws);
  }

  final lines = str.split('\n');
  final contentHeight = lines.length;

  if (contentHeight >= height) return str;

  // Find widest line
  var maxWidth = 0;
  for (final line in lines) {
    final w = stringWidth(line);
    if (w > maxWidth) maxWidth = w;
  }

  final totalPad = height - contentHeight;
  final topPad = (totalPad * pos).toInt();
  final bottomPad = totalPad - topPad;

  final emptyLineRaw = renderWhitespace(maxWidth, ws.chars);
  final emptyLine =
      ws.style != null ? ws.style!.render(emptyLineRaw) : emptyLineRaw;

  final buf = StringBuffer();
  for (var i = 0; i < topPad; i++) {
    buf.write(emptyLine);
    buf.write('\n');
  }
  buf.write(str);
  for (var i = 0; i < bottomPad; i++) {
    buf.write('\n');
    buf.write(emptyLine);
  }

  return buf.toString();
}
