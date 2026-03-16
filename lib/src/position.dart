// Ported from charmbracelet/lipgloss position.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'ansi/width.dart';
import 'whitespace.dart';

/// Position constants.
const double posTop = 0.0;
const double posBottom = 1.0;
const double posCenter = 0.5;
const double posLeft = 0.0;
const double posRight = 1.0;

/// Place a string within a region of [width] x [height].
String place(
  int width,
  int height,
  double hPos,
  double vPos,
  String str, {
  String whitespaceChars = ' ',
}) {
  return placeVertical(
    height,
    vPos,
    placeHorizontal(width, hPos, str, whitespaceChars: whitespaceChars),
    whitespaceChars: whitespaceChars,
  );
}

/// Place a string horizontally within [width].
String placeHorizontal(
  int width,
  double pos,
  String str, {
  String whitespaceChars = ' ',
}) {
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
    final leftPad = (totalPad * pos).round();
    final rightPad = totalPad - leftPad;

    if (leftPad > 0) {
      buf.write(renderWhitespace(leftPad, whitespaceChars));
    }
    buf.write(line);
    if (rightPad > 0) {
      buf.write(renderWhitespace(rightPad, whitespaceChars));
    }

    if (i < lines.length - 1) buf.write('\n');
  }

  return buf.toString();
}

/// Place a string vertically within [height] lines.
String placeVertical(
  int height,
  double pos,
  String str, {
  String whitespaceChars = ' ',
}) {
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
  final topPad = (totalPad * pos).round();
  final bottomPad = totalPad - topPad;

  final emptyLine = renderWhitespace(maxWidth, whitespaceChars);

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
