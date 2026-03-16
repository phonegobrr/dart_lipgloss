// Ported from charmbracelet/lipgloss wrap.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'ansi/parser.dart';
import 'ansi/strip.dart';
import 'ansi/width.dart';

/// ANSI-aware word wrapping to [limit] visible cells.
String wordWrap(String s, int limit, [String breakpoints = ' ']) {
  if (limit <= 0) return s;

  final lines = s.split('\n');
  final result = <String>[];

  for (final line in lines) {
    if (stringWidth(line) <= limit) {
      result.add(line);
      continue;
    }

    final wrapped = _wrapLine(line, limit, breakpoints);
    result.addAll(wrapped);
  }

  return result.join('\n');
}

/// Wrap a single line at word boundaries.
List<String> _wrapLine(String line, int limit, String breakpoints) {
  final segments = parseAnsiSegments(line);
  final result = <String>[];
  final currentLine = StringBuffer();
  var currentWidth = 0;
  final penState = AnsiPenState();
  String? activeLink;

  for (final segment in segments) {
    if (segment.isAnsi) {
      final seq = segment.text;
      penState.feedSequence(seq);

      // Track OSC 8 hyperlink state
      if (seq.startsWith('\x1b]8;')) {
        final isClose = seq == '\x1b]8;;\x1b\\' || seq == '\x1b]8;;\x07';
        if (isClose) {
          activeLink = null;
        } else {
          activeLink = seq;
        }
      }

      currentLine.write(seq);
      continue;
    }

    // Process plain text
    final words = _splitKeepDelimiters(segment.text, breakpoints);
    for (final word in words) {
      final wordWidth = stringWidth(word);

      if (currentWidth + wordWidth > limit && currentWidth > 0) {
        // Need to wrap - close current hyperlink and style, start new line
        if (activeLink != null) {
          currentLine.write('\x1b]8;;\x1b\\');
        }
        if (penState.hasStyle) {
          currentLine.write('\x1b[0m');
        }
        result.add(currentLine.toString());
        currentLine.clear();
        currentWidth = 0;

        // Reapply styles and hyperlink on new line
        if (penState.hasStyle) {
          currentLine.write(penState.currentStyle);
        }
        if (activeLink != null) {
          currentLine.write(activeLink);
        }

        // Skip leading spaces on new line
        final trimmed = word.trimLeft();
        if (trimmed.isNotEmpty) {
          currentLine.write(trimmed);
          currentWidth = stringWidth(trimmed);
        }
      } else {
        currentLine.write(word);
        currentWidth += wordWidth;
      }
    }
  }

  if (currentLine.isNotEmpty) {
    result.add(currentLine.toString());
  }

  if (result.isEmpty) result.add('');
  return result;
}

/// Split text while keeping delimiters.
List<String> _splitKeepDelimiters(String text, String delimiters) {
  if (text.isEmpty) return [''];
  final result = <String>[];
  final buf = StringBuffer();

  for (var i = 0; i < text.length; i++) {
    if (delimiters.contains(text[i])) {
      if (buf.isNotEmpty) {
        result.add(buf.toString());
        buf.clear();
      }
      result.add(text[i]);
    } else {
      buf.write(text[i]);
    }
  }

  if (buf.isNotEmpty) {
    result.add(buf.toString());
  }

  return result;
}

/// Hard-wrap a string to [limit] cells, breaking mid-word if necessary.
String hardWrap(String s, int limit) {
  if (limit <= 0) return s;

  final lines = s.split('\n');
  final result = <String>[];

  for (final line in lines) {
    if (stringWidth(line) <= limit) {
      result.add(line);
      continue;
    }

    final stripped = stripAnsi(line);
    final buf = StringBuffer();
    var currentWidth = 0;

    for (final rune in stripped.runes) {
      final char = String.fromCharCode(rune);
      final w = runeWidth(rune);

      if (currentWidth + w > limit) {
        result.add(buf.toString());
        buf.clear();
        currentWidth = 0;
      }

      buf.write(char);
      currentWidth += w;
    }

    if (buf.isNotEmpty) {
      result.add(buf.toString());
    }
  }

  return result.join('\n');
}
