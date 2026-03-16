// Ported from charmbracelet/x/ansi
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'parser.dart';
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
  var hasActiveSgr = false;

  final stripped = stripAnsi(s);
  if (stripped.isEmpty) return s;

  var i = 0;
  final codeUnits = s.codeUnits;

  while (i < codeUnits.length && currentWidth < targetWidth) {
    if (codeUnits[i] == 0x1B && i + 1 < codeUnits.length) {
      final next = codeUnits[i + 1];

      if (next == 0x5B) {
        // CSI sequence: ESC [ ... final_byte
        final escStart = i;
        i += 2; // skip ESC [
        while (i < codeUnits.length && codeUnits[i] < 0x40) {
          i++;
        }
        if (i < codeUnits.length) i++; // skip final byte
        final seq = String.fromCharCodes(codeUnits.sublist(escStart, i));
        buf.write(seq);
        // Track SGR state
        if (seq == '\x1b[0m' || seq == '\x1b[m') {
          hasActiveSgr = false;
        } else if (seq.endsWith('m')) {
          hasActiveSgr = true;
        }
        continue;
      }

      if (next == 0x5D) {
        // OSC sequence: ESC ] ... (BEL | ESC \)
        final escStart = i;
        i += 2; // skip ESC ]
        while (i < codeUnits.length) {
          if (codeUnits[i] == 0x07) {
            i++;
            break;
          }
          if (codeUnits[i] == 0x1B &&
              i + 1 < codeUnits.length &&
              codeUnits[i + 1] == 0x5C) {
            i += 2;
            break;
          }
          i++;
        }
        buf.write(String.fromCharCodes(codeUnits.sublist(escStart, i)));
        // OSC sequences do not affect SGR state
        continue;
      }

      // Other single-char escape
      buf.writeCharCode(codeUnits[i]);
      buf.writeCharCode(codeUnits[i + 1]);
      i += 2;
      continue;
    }

    // Regular character - check its width
    int codePoint;
    if (codeUnits[i] >= 0xD800 &&
        codeUnits[i] <= 0xDBFF &&
        i + 1 < codeUnits.length) {
      codePoint = 0x10000 +
          ((codeUnits[i] - 0xD800) << 10) +
          (codeUnits[i + 1] - 0xDC00);
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

  // Close any active SGR style (not OSC sequences)
  if (hasActiveSgr) {
    buf.write('\x1b[0m');
  }

  return buf.toString();
}

/// Raw truncation from the left to [targetWidth] visible cells.
/// ANSI-aware: preserves styling by walking the original string
/// and tracking SGR state.
String _truncateLeftRaw(String s, int targetWidth) {
  // First, compute total visible width and determine the start position
  final segments = parseAnsiSegments(s);
  var totalVisibleWidth = 0;
  for (final seg in segments) {
    if (!seg.isAnsi) {
      totalVisibleWidth += stringWidth(seg.text);
    }
  }

  if (totalVisibleWidth <= targetWidth) return s;

  final skipWidth = totalVisibleWidth - targetWidth;

  // Walk from left, skipping `skipWidth` visible cells, then emit the rest
  final buf = StringBuffer();
  var skipped = 0;
  var emitting = false;
  final pendingSgr = StringBuffer();
  var hasPendingSgr = false;

  for (final seg in segments) {
    if (seg.isAnsi) {
      final seq = seg.text;
      if (seq.startsWith('\x1b[') && seq.endsWith('m')) {
        if (seq == '\x1b[0m' || seq == '\x1b[m') {
          pendingSgr.clear();
          hasPendingSgr = false;
        } else {
          pendingSgr.write(seq);
          hasPendingSgr = true;
        }
      }
      if (emitting) {
        buf.write(seq);
      }
      continue;
    }

    // Text segment
    if (emitting) {
      buf.write(seg.text);
      continue;
    }

    // Still skipping
    for (final rune in seg.text.runes) {
      final w = runeWidth(rune);
      if (skipped + w > skipWidth) {
        // Start emitting from here
        emitting = true;
        if (hasPendingSgr) {
          buf.write(pendingSgr);
        }
        buf.write(String.fromCharCode(rune));
      } else {
        skipped += w;
        if (skipped >= skipWidth) {
          emitting = true;
          if (hasPendingSgr) {
            buf.write(pendingSgr);
          }
        }
      }
    }
  }

  // Close any active SGR style
  if (hasPendingSgr && buf.isNotEmpty) {
    buf.write('\x1b[0m');
  }

  return buf.toString();
}
