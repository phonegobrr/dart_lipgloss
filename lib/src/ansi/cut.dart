// Ported from charmbracelet/x/ansi
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'package:characters/characters.dart';

import 'parser.dart';
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

  // Parse string into ANSI and text segments
  final segments = parseAnsiSegments(s);

  final buf = StringBuffer();
  // Track accumulated SGR sequences before the range
  final pendingSgr = StringBuffer();
  var hasPendingSgr = false;
  // Track OSC 8 hyperlink state
  String? activeOscOpen;

  var visiblePos = 0;
  var wroteVisibleChar = false;

  for (final segment in segments) {
    if (visiblePos >= end) break;

    if (segment.isAnsi) {
      final seq = segment.text;
      _handleAnsiSegment(
        seq: seq,
        visiblePos: visiblePos,
        start: start,
        end: end,
        buf: buf,
        pendingSgr: pendingSgr,
        wroteVisibleChar: wroteVisibleChar,
        onPendingSgrChanged: (v) => hasPendingSgr = v,
        hasPendingSgr: hasPendingSgr,
        activeOscOpen: activeOscOpen,
        onActiveOscChanged: (v) => activeOscOpen = v,
      );
    } else {
      // Text segment — iterate by grapheme cluster for proper boundaries
      final graphemes = segment.text.characters;
      for (final grapheme in graphemes) {
        if (visiblePos >= end) break;

        // Compute true display width for this grapheme.
        // stringWidth() may return 1 for zero-width-only clusters,
        // so we check the base rune directly.
        final runes = grapheme.runes;
        int w;
        if (runes.length == 1) {
          w = runeWidth(runes.first);
        } else {
          // Multi-rune grapheme: find first non-zero-width rune
          w = 0;
          for (final r in runes) {
            final rw = runeWidth(r);
            if (rw > 0) {
              w = rw;
              break;
            }
          }
          // Emoji ZWJ sequences that start with visible codepoints
          if (w == 0 && runes.first >= 0x1F000) {
            w = 2;
          }
        }

        // Skip zero-width graphemes (pure combining marks, control chars)
        if (w == 0) continue;

        if (visiblePos + w > start && visiblePos < end) {
          // First visible char: emit pending state
          if (!wroteVisibleChar) {
            wroteVisibleChar = true;
            if (hasPendingSgr && pendingSgr.isNotEmpty) {
              buf.write(pendingSgr);
            }
            if (activeOscOpen != null) {
              buf.write(activeOscOpen);
            }
          }
          buf.write(grapheme);
        }

        visiblePos += w;
      }
    }
  }

  // If we wrote no visible characters, return empty
  if (!wroteVisibleChar) return '';

  // Close active OSC 8 hyperlink
  if (activeOscOpen != null) {
    buf.write('\x1b]8;;\x1b\\');
  }

  // Close active SGR style
  if (hasPendingSgr) {
    buf.write('\x1b[0m');
  }

  return buf.toString();
}

void _handleAnsiSegment({
  required String seq,
  required int visiblePos,
  required int start,
  required int end,
  required StringBuffer buf,
  required StringBuffer pendingSgr,
  required bool wroteVisibleChar,
  required void Function(bool) onPendingSgrChanged,
  required bool hasPendingSgr,
  required String? activeOscOpen,
  required void Function(String?) onActiveOscChanged,
}) {
  final inRange = visiblePos >= start && visiblePos < end;

  // CSI/SGR sequences
  if (seq.startsWith('\x1b[')) {
    final isSgrReset = seq == '\x1b[0m' || seq == '\x1b[m';
    final isSgr = seq.endsWith('m');

    if (isSgr) {
      if (inRange && wroteVisibleChar) {
        // Already writing visible content — emit directly
        buf.write(seq);
        if (isSgrReset) {
          pendingSgr.clear();
          onPendingSgrChanged(false);
        } else {
          pendingSgr.write(seq);
          onPendingSgrChanged(true);
        }
      } else {
        // Before range or in range but before first visible char —
        // accumulate into pending state (will be replayed on first visible char)
        if (isSgrReset) {
          pendingSgr.clear();
          onPendingSgrChanged(false);
        } else {
          pendingSgr.write(seq);
          onPendingSgrChanged(true);
        }
      }
    } else if (inRange && wroteVisibleChar) {
      // Non-SGR CSI in range after visible content — emit directly
      buf.write(seq);
    }
    return;
  }

  // OSC sequences
  if (seq.startsWith('\x1b]8;')) {
    final isClose = seq == '\x1b]8;;\x1b\\' || seq == '\x1b]8;;\x07';
    if (isClose) {
      if (inRange && wroteVisibleChar) {
        buf.write(seq);
      }
      onActiveOscChanged(null);
    } else {
      if (inRange && wroteVisibleChar) {
        buf.write(seq);
        onActiveOscChanged(seq);
      } else {
        // Before range or before first visible char — remember it
        onActiveOscChanged(seq);
      }
    }
    return;
  }

  // Other ANSI — pass through if in range and after visible content
  if (inRange && wroteVisibleChar) {
    buf.write(seq);
  }
}
