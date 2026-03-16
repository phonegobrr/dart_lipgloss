// Ported from charmbracelet/lipgloss align.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'ansi/width.dart';

/// Align text horizontally within a bounding box of [width].
///
/// [pos] is 0.0 for left, 0.5 for center, 1.0 for right.
String alignTextHorizontal(String str, double pos, int width, [String? styleOpen, String? styleClose]) {
  final lines = str.split('\n');
  final buf = StringBuffer();

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final lineWidth = stringWidth(line);

    if (lineWidth >= width) {
      buf.write(line);
    } else {
      final totalPad = width - lineWidth;
      final leftPad = (totalPad * pos).round();
      final rightPad = totalPad - leftPad;

      final leftStr = ' ' * leftPad;
      final rightStr = ' ' * rightPad;

      if (styleOpen != null && styleClose != null) {
        buf.write('$styleOpen$leftStr$styleClose$line$styleOpen$rightStr$styleClose');
      } else {
        buf.write('$leftStr$line$rightStr');
      }
    }

    if (i < lines.length - 1) buf.write('\n');
  }

  return buf.toString();
}

/// Align text vertically within a bounding box of [height] lines.
///
/// [pos] is 0.0 for top, 0.5 for center, 1.0 for bottom.
String alignTextVertical(String str, double pos, int height, [String? styleOpen, String? styleClose]) {
  final lines = str.split('\n');
  final contentHeight = lines.length;

  if (contentHeight >= height) return str;

  final totalPad = height - contentHeight;
  final topPad = (totalPad * pos).round();
  final bottomPad = totalPad - topPad;

  // Determine width for empty lines
  var maxWidth = 0;
  for (final line in lines) {
    final w = stringWidth(line);
    if (w > maxWidth) maxWidth = w;
  }

  final emptyLine = styleOpen != null && styleClose != null
      ? '$styleOpen${' ' * maxWidth}$styleClose'
      : ' ' * maxWidth;

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
