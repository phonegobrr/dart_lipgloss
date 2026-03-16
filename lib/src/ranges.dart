// Ported from charmbracelet/lipgloss ranges.go, runes.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'ansi/cut.dart' as ansi_cut;
import 'ansi/width.dart';
import 'style.dart';

/// A style range for applying a style to a substring by visible cell index.
class StyleRange {
  final int start;
  final int end;
  final Style style;
  const StyleRange(this.start, this.end, this.style);
}

/// Apply different styles to specific visible-cell ranges.
/// ANSI-aware: uses ansi cut to preserve existing styling.
String styleRanges(String s, List<StyleRange> ranges) {
  if (ranges.isEmpty) return s;

  // Sort ranges by start position
  final sorted = List<StyleRange>.from(ranges)
    ..sort((a, b) => a.start.compareTo(b.start));

  final totalWidth = stringWidth(s);
  final buf = StringBuffer();
  var pos = 0;

  for (final range in sorted) {
    final rangeStart = range.start.clamp(0, totalWidth);
    final rangeEnd = range.end.clamp(0, totalWidth);

    // Write unstyled content before this range
    if (rangeStart > pos) {
      buf.write(ansi_cut.cut(s, pos, rangeStart));
    }

    // Write styled content
    if (rangeStart < rangeEnd) {
      final content = ansi_cut.cut(s, rangeStart, rangeEnd);
      buf.write(range.style.render(content));
    }

    pos = rangeEnd;
  }

  // Write remaining unstyled content
  if (pos < totalWidth) {
    buf.write(ansi_cut.cut(s, pos, totalWidth));
  }

  return buf.toString();
}

/// Apply styles to specific rune indices.
/// Groups consecutive indices for efficiency.
String styleRunes(
  String str,
  List<int> indices,
  Style matched,
  Style unmatched,
) {
  if (indices.isEmpty) return unmatched.render(str);

  final indexSet = indices.toSet();
  final runes = str.runes.toList();
  final buf = StringBuffer();

  // Group consecutive runes for efficiency
  var i = 0;
  while (i < runes.length) {
    final isMatched = indexSet.contains(i);
    final groupBuf = StringBuffer();
    var j = i;
    while (j < runes.length && indexSet.contains(j) == isMatched) {
      groupBuf.write(String.fromCharCode(runes[j]));
      j++;
    }
    final group = groupBuf.toString();
    buf.write(isMatched ? matched.render(group) : unmatched.render(group));
    i = j;
  }

  return buf.toString();
}
