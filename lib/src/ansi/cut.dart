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
/// Any OSC 8 hyperlink active at the end is properly closed.
String cut(String s, int start, int end) {
  if (start < 0) start = 0;
  if (end <= start) return '';
  if (s.isEmpty) return '';

  // We use a two-pass approach:
  // 1. Walk the string tracking ANSI state and visible positions
  // 2. Build the output with proper state management

  final buf = StringBuffer();

  // Track accumulated SGR sequences before the range
  final pendingSgr = StringBuffer();
  var hasActiveSgr = false;
  // Track OSC 8 hyperlink state
  String? activeOscOpen;

  var visiblePos = 0;
  var wroteVisibleChar = false;

  var i = 0;
  final codeUnits = s.codeUnits;

  while (i < codeUnits.length && visiblePos < end) {
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

        final isSgrReset = seq == '\x1b[0m' || seq == '\x1b[m';
        final isSgr = seq.endsWith('m');

        if (visiblePos >= start && visiblePos < end) {
          // In range: emit directly
          buf.write(seq);
          if (isSgrReset) {
            hasActiveSgr = false;
          } else if (isSgr) {
            hasActiveSgr = true;
          }
        } else if (visiblePos < start && isSgr) {
          // Before range: accumulate SGR state to replay later
          if (isSgrReset) {
            pendingSgr.clear();
            hasActiveSgr = false;
          } else {
            pendingSgr.write(seq);
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
        final seq = String.fromCharCodes(codeUnits.sublist(escStart, i));

        // Track OSC 8 hyperlink state
        if (seq.startsWith('\x1b]8;')) {
          // Check if it's a close (empty URL: \x1b]8;;\x1b\\)
          final isClose = seq == '\x1b]8;;\x1b\\' || seq == '\x1b]8;;\x07';
          if (isClose) {
            if (visiblePos >= start && visiblePos < end) {
              buf.write(seq);
            }
            activeOscOpen = null;
          } else {
            if (visiblePos >= start && visiblePos < end) {
              buf.write(seq);
              activeOscOpen = seq;
            } else if (visiblePos < start) {
              // Before range — remember it
              activeOscOpen = seq;
            }
          }
        } else {
          // Non-hyperlink OSC — pass through if in range
          if (visiblePos >= start && visiblePos < end) {
            buf.write(seq);
          }
        }
        continue;
      }

      // Other single-char escape
      if (visiblePos >= start && visiblePos < end) {
        buf.writeCharCode(codeUnits[i]);
        buf.writeCharCode(codeUnits[i + 1]);
      }
      i += 2;
      continue;
    }

    // Regular character — measure visible width
    // Handle surrogate pairs for code point
    int codePoint;
    int charLen;
    if (codeUnits[i] >= 0xD800 &&
        codeUnits[i] <= 0xDBFF &&
        i + 1 < codeUnits.length) {
      codePoint = 0x10000 +
          ((codeUnits[i] - 0xD800) << 10) +
          (codeUnits[i + 1] - 0xDC00);
      charLen = 2;
    } else {
      codePoint = codeUnits[i];
      charLen = 1;
    }

    // Check for combining characters following this code point
    // Consume all zero-width continuations as part of the same grapheme
    var totalCharLen = charLen;
    var peekIdx = i + charLen;
    while (peekIdx < codeUnits.length) {
      int peekCp;
      int peekLen;
      if (codeUnits[peekIdx] >= 0xD800 &&
          codeUnits[peekIdx] <= 0xDBFF &&
          peekIdx + 1 < codeUnits.length) {
        peekCp = 0x10000 +
            ((codeUnits[peekIdx] - 0xD800) << 10) +
            (codeUnits[peekIdx + 1] - 0xDC00);
        peekLen = 2;
      } else {
        peekCp = codeUnits[peekIdx];
        peekLen = 1;
      }
      // If it's zero-width (combining mark, ZWJ, etc.), consume it
      if (runeWidth(peekCp) == 0 && peekCp != 0x1B) {
        totalCharLen += peekLen;
        peekIdx += peekLen;
      } else {
        break;
      }
    }

    final w = runeWidth(codePoint);

    if (visiblePos + w > start && visiblePos < end) {
      // First visible char: emit pending SGR and OSC state
      if (!wroteVisibleChar) {
        wroteVisibleChar = true;
        if (hasActiveSgr && pendingSgr.isNotEmpty) {
          buf.write(pendingSgr);
        }
        if (activeOscOpen != null) {
          buf.write(activeOscOpen);
        }
      }
      // Write the full grapheme (base + combiners)
      for (var k = 0; k < totalCharLen; k++) {
        buf.writeCharCode(codeUnits[i + k]);
      }
    }

    visiblePos += w;
    i += totalCharLen;
  }

  // If we wrote no visible characters, return empty regardless of ANSI state
  if (!wroteVisibleChar) return '';

  // Close active OSC 8 hyperlink
  if (activeOscOpen != null) {
    buf.write('\x1b]8;;\x1b\\');
  }

  // Close active SGR style
  if (hasActiveSgr) {
    buf.write('\x1b[0m');
  }

  return buf.toString();
}
