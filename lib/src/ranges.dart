// Ported from charmbracelet/lipgloss ranges.go, runes.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'style.dart';

/// A style range for applying a style to a substring by character index.
class StyleRange {
  final int start;
  final int end;
  final Style style;
  const StyleRange(this.start, this.end, this.style);
}

/// Apply different styles to specific character ranges.
String styleRanges(String s, List<StyleRange> ranges) {
  if (ranges.isEmpty) return s;

  // Sort ranges by start position
  final sorted = List<StyleRange>.from(ranges)
    ..sort((a, b) => a.start.compareTo(b.start));

  final runes = s.runes.toList();
  final buf = StringBuffer();
  var pos = 0;

  for (final range in sorted) {
    // Write unstyled content before this range
    if (range.start > pos) {
      buf.write(String.fromCharCodes(runes.sublist(pos, range.start.clamp(0, runes.length))));
    }

    // Write styled content
    final rangeEnd = range.end.clamp(0, runes.length);
    final rangeStart = range.start.clamp(0, runes.length);
    if (rangeStart < rangeEnd) {
      final content = String.fromCharCodes(runes.sublist(rangeStart, rangeEnd));
      buf.write(range.style.render(content));
    }

    pos = rangeEnd;
  }

  // Write remaining unstyled content
  if (pos < runes.length) {
    buf.write(String.fromCharCodes(runes.sublist(pos)));
  }

  return buf.toString();
}

/// Apply styles to specific rune indices.
String styleRunes(
  String str,
  List<int> indices,
  Style matched,
  Style unmatched,
) {
  final indexSet = indices.toSet();
  final runes = str.runes.toList();
  final buf = StringBuffer();

  for (var i = 0; i < runes.length; i++) {
    final char = String.fromCharCode(runes[i]);
    if (indexSet.contains(i)) {
      buf.write(matched.render(char));
    } else {
      buf.write(unmatched.render(char));
    }
  }

  return buf.toString();
}
