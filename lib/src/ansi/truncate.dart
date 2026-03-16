// Ported from charmbracelet/x/ansi
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'package:characters/characters.dart';

import 'strip.dart';
import 'width.dart';

/// Truncate [s] to [width] visible cells from the right, appending [tail].
/// Preserves ANSI escape sequences.
String truncate(String s, int width, [String tail = '']) {
  if (width < 0) width = 0;

  final sw = stringWidth(s);
  if (sw <= width) return s;

  final tailWidth = stringWidth(tail);
  if (tailWidth >= width) {
    // Tail is wider than available space; just return truncated tail
    return _truncateRaw(tail, width);
  }

  final targetWidth = width - tailWidth;
  return _truncateRaw(s, targetWidth) + tail;
}

/// Truncate [s] to [width] visible cells from the left, prepending [prefix].
String truncateLeft(String s, int width, [String prefix = '']) {
  if (width < 0) width = 0;

  final sw = stringWidth(s);
  if (sw <= width) return s;

  final prefixWidth = stringWidth(prefix);
  if (prefixWidth >= width) {
    return _truncateRaw(prefix, width);
  }

  final targetWidth = width - prefixWidth;
  return prefix + _truncateLeftRaw(s, targetWidth);
}

/// Raw truncation from the right to [targetWidth] visible cells.
/// Walks through the string preserving ANSI sequences, closing any active
/// styles at the truncation point.
String _truncateRaw(String s, int targetWidth) {
  final buf = StringBuffer();
  var currentWidth = 0;
  var inEscape = false;
  var escBuf = StringBuffer();
  var hasActiveStyle = false;

  final stripped = stripAnsi(s);
  if (stripped.isEmpty) return s;

  // Walk through original string character by character
  var i = 0;
  final codeUnits = s.codeUnits;
  while (i < codeUnits.length && currentWidth < targetWidth) {
    if (codeUnits[i] == 0x1B) {
      // Start of ANSI escape
      inEscape = true;
      escBuf = StringBuffer();
      escBuf.writeCharCode(0x1B);
      i++;
      continue;
    }

    if (inEscape) {
      escBuf.writeCharCode(codeUnits[i]);
      // Check for end of CSI sequence
      if (codeUnits[i] >= 0x40 && codeUnits[i] <= 0x7E && codeUnits[i] != 0x5B) {
        final seq = escBuf.toString();
        buf.write(seq);
        // Track whether we have an active style or a reset
        if (seq == '\x1b[0m' || seq == '\x1b[m') {
          hasActiveStyle = false;
        } else {
          hasActiveStyle = true;
        }
        inEscape = false;
      }
      // Check for OSC sequence end (BEL)
      if (codeUnits[i] == 0x07) {
        buf.write(escBuf);
        inEscape = false;
      }
      i++;
      continue;
    }

    // Regular character - check its width
    // Handle surrogate pairs
    int codePoint;
    if (codeUnits[i] >= 0xD800 && codeUnits[i] <= 0xDBFF && i + 1 < codeUnits.length) {
      codePoint = 0x10000 + ((codeUnits[i] - 0xD800) << 10) + (codeUnits[i + 1] - 0xDC00);
      final w = runeWidth(codePoint);
      if (currentWidth + w > targetWidth) break;
      currentWidth += w;
      buf.writeCharCode(codeUnits[i]);
      buf.writeCharCode(codeUnits[i + 1]);
      i += 2;
    } else {
      codePoint = codeUnits[i];
      final w = runeWidth(codePoint);
      if (currentWidth + w > targetWidth) break;
      currentWidth += w;
      buf.writeCharCode(codeUnits[i]);
      i++;
    }
  }

  // Close any active style
  if (hasActiveStyle) {
    buf.write('\x1b[0m');
  }

  return buf.toString();
}

/// Raw truncation from the left to [targetWidth] visible cells.
String _truncateLeftRaw(String s, int targetWidth) {
  // Strip ANSI, measure graphemes from right to left
  final stripped = stripAnsi(s);
  final chars = stripped.characters.toList();

  var width = 0;
  var startIdx = chars.length;
  for (var i = chars.length - 1; i >= 0; i--) {
    final w = stringWidth(chars[i]);
    if (width + w > targetWidth) break;
    width += w;
    startIdx = i;
  }

  return chars.sublist(startIdx).join();
}

/// ANSI-aware substring by visible cell position [start] to [end].
String cut(String s, int start, int end) {
  if (start < 0) start = 0;
  if (end < start) return '';

  final stripped = stripAnsi(s);
  final chars = stripped.characters.toList();

  var currentPos = 0;
  final buf = StringBuffer();

  for (final grapheme in chars) {
    final w = stringWidth(grapheme);
    if (currentPos >= end) break;
    if (currentPos + w > start) {
      buf.write(grapheme);
    }
    currentPos += w;
  }

  return buf.toString();
}
