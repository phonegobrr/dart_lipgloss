// Ported from charmbracelet/lipgloss whitespace.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'ansi/width.dart';

/// Renders whitespace of a given width, cycling through [chars].
String renderWhitespace(int width, [String chars = ' ']) {
  if (width <= 0) return '';
  if (chars.isEmpty || chars == ' ') return ' ' * width;

  final charWidth = stringWidth(chars);
  if (charWidth == 0) return ' ' * width;

  final buf = StringBuffer();
  var remaining = width;
  var i = 0;
  final charList = chars.split('');

  while (remaining > 0) {
    final c = charList[i % charList.length];
    final cw = stringWidth(c);
    if (cw > remaining) break;
    buf.write(c);
    remaining -= cw;
    i++;
  }

  // Fill any remaining space
  while (remaining > 0) {
    buf.write(' ');
    remaining--;
  }

  return buf.toString();
}
