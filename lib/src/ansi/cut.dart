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

        final w = stringWidth(grapheme);

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
  // CSI/SGR sequences
  if (seq.startsWith('\x1b[')) {
    final isSgrReset = seq == '\x1b[0m' || seq == '\x1b[m';
    final isSgr = seq.endsWith('m');
    // Selective resets (e.g. \x1b[22m, \x1b[39m) are SGR but not full resets

    if (visiblePos >= start && visiblePos < end) {
      buf.write(seq);
      if (isSgr) {
        if (isSgrReset) {
          pendingSgr.clear();
          onPendingSgrChanged(false);
        } else {
          pendingSgr.write(seq);
          onPendingSgrChanged(true);
        }
      }
    } else if (visiblePos < start && isSgr) {
      if (isSgrReset) {
        pendingSgr.clear();
        onPendingSgrChanged(false);
      } else {
        pendingSgr.write(seq);
        onPendingSgrChanged(true);
      }
    }
    return;
  }

  // OSC sequences
  if (seq.startsWith('\x1b]8;')) {
    final isClose = seq == '\x1b]8;;\x1b\\' || seq == '\x1b]8;;\x07';
    if (isClose) {
      if (visiblePos >= start && visiblePos < end) {
        buf.write(seq);
      }
      onActiveOscChanged(null);
    } else {
      if (visiblePos >= start && visiblePos < end) {
        buf.write(seq);
        onActiveOscChanged(seq);
      } else if (visiblePos < start) {
        onActiveOscChanged(seq);
      }
    }
    return;
  }

  // Other ANSI — pass through if in range
  if (visiblePos >= start && visiblePos < end) {
    buf.write(seq);
  }
}
