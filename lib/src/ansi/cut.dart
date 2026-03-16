// Ported from charmbracelet/x/ansi
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'width.dart';

/// ANSI-aware substring by visible cell position [start] (inclusive)
/// to [end] (exclusive).
///
/// Walks through [s] tracking visible cell positions while preserving
/// ANSI escape sequences that are active within the selected range.
/// Any SGR style active at the end of the cut region is properly closed.
String cut(String s, int start, int end) {
  if (start < 0) start = 0;
  if (end <= start) return '';
  if (s.isEmpty) return '';

  final buf = StringBuffer();
  var visiblePos = 0;
  var hasActiveSgr = false;
  var inRange = false;

  var i = 0;
  final codeUnits = s.codeUnits;

  while (i < codeUnits.length) {
    if (codeUnits[i] == 0x1B && i + 1 < codeUnits.length) {
      final next = codeUnits[i + 1];

      if (next == 0x5B) {
        // CSI sequence: ESC [ ... final_byte
        final escStart = i;
        i += 2;
        while (i < codeUnits.length && codeUnits[i] < 0x40) {
          i++;
        }
        if (i < codeUnits.length) i++; // skip final byte
        final seq = String.fromCharCodes(codeUnits.sublist(escStart, i));

        // Track SGR state
        final isSgrReset = seq == '\x1b[0m' || seq == '\x1b[m';
        final isSgr = seq.endsWith('m');

        if (inRange || visiblePos >= start) {
          // Include ANSI sequences that affect the visible range
          buf.write(seq);
          if (isSgrReset) {
            hasActiveSgr = false;
          } else if (isSgr) {
            hasActiveSgr = true;
          }
        } else if (isSgr) {
          // Track SGR state even before range, so we can reapply
          if (isSgrReset) {
            hasActiveSgr = false;
          } else {
            hasActiveSgr = true;
          }
        }
        continue;
      }

      if (next == 0x5D) {
        // OSC sequence: ESC ] ... (BEL | ESC \)
        final escStart = i;
        i += 2;
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
        // Include OSC sequences if we're in range
        if (inRange || visiblePos >= start) {
          buf.write(String.fromCharCodes(codeUnits.sublist(escStart, i)));
        }
        continue;
      }

      // Other single-char escape — pass through if in range
      if (inRange || visiblePos >= start) {
        buf.writeCharCode(codeUnits[i]);
        buf.writeCharCode(codeUnits[i + 1]);
      }
      i += 2;
      continue;
    }

    // Regular character — check visible position
    int codePoint;
    int charLen;
    if (codeUnits[i] >= 0xD800 &&
        codeUnits[i] <= 0xDBFF &&
        i + 1 < codeUnits.length) {
      // Surrogate pair
      codePoint =
          0x10000 + ((codeUnits[i] - 0xD800) << 10) + (codeUnits[i + 1] - 0xDC00);
      charLen = 2;
    } else {
      codePoint = codeUnits[i];
      charLen = 1;
    }

    final w = runeWidth(codePoint);

    if (visiblePos + w > start && visiblePos < end) {
      if (!inRange) inRange = true;
      for (var k = 0; k < charLen; k++) {
        buf.writeCharCode(codeUnits[i + k]);
      }
    }

    visiblePos += w;
    i += charLen;

    // Past end — stop
    if (visiblePos >= end) break;
  }

  // Close any active SGR style
  if (hasActiveSgr) {
    buf.write('\x1b[0m');
  }

  return buf.toString();
}
