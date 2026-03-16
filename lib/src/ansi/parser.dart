// Ported from charmbracelet/x/ansi
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Tracks ANSI pen state while walking through a string.
///
/// Used by WrapWriter and truncate to reapply styles across line breaks.
class AnsiPenState {
  final List<String> _activeSequences = [];

  /// Feed an ANSI escape sequence to the pen state tracker.
  void feedSequence(String sequence) {
    if (sequence == '\x1b[0m' || sequence == '\x1b[m') {
      // Reset - clear all active sequences
      _activeSequences.clear();
    } else if (sequence.startsWith('\x1b[')) {
      _activeSequences.add(sequence);
    }
  }

  /// Get the current style state as a string to reapply.
  String get currentStyle => _activeSequences.join();

  /// Whether there's any active styling.
  bool get hasStyle => _activeSequences.isNotEmpty;

  /// Reset pen state.
  void reset() => _activeSequences.clear();
}

/// Walk a string and split it into segments of plain text and ANSI sequences.
List<StringSegment> parseAnsiSegments(String s) {
  final segments = <StringSegment>[];
  final buf = StringBuffer();
  var i = 0;
  final units = s.codeUnits;

  while (i < units.length) {
    if (units[i] == 0x1B && i + 1 < units.length) {
      // Flush plain text buffer
      if (buf.isNotEmpty) {
        segments.add(StringSegment(buf.toString(), isAnsi: false));
        buf.clear();
      }

      final escBuf = StringBuffer();
      escBuf.writeCharCode(0x1B);
      i++;

      if (i < units.length && units[i] == 0x5B) {
        // CSI sequence
        escBuf.writeCharCode(units[i]);
        i++;
        while (i < units.length) {
          escBuf.writeCharCode(units[i]);
          if (units[i] >= 0x40 && units[i] <= 0x7E) {
            i++;
            break;
          }
          i++;
        }
        segments.add(StringSegment(escBuf.toString(), isAnsi: true));
      } else if (i < units.length && units[i] == 0x5D) {
        // OSC sequence
        escBuf.writeCharCode(units[i]);
        i++;
        while (i < units.length) {
          if (units[i] == 0x07) {
            escBuf.writeCharCode(units[i]);
            i++;
            break;
          }
          if (units[i] == 0x1B && i + 1 < units.length && units[i + 1] == 0x5C) {
            escBuf.writeCharCode(units[i]);
            escBuf.writeCharCode(units[i + 1]);
            i += 2;
            break;
          }
          escBuf.writeCharCode(units[i]);
          i++;
        }
        segments.add(StringSegment(escBuf.toString(), isAnsi: true));
      } else {
        // Single char escape
        if (i < units.length) {
          escBuf.writeCharCode(units[i]);
          i++;
        }
        segments.add(StringSegment(escBuf.toString(), isAnsi: true));
      }
    } else {
      buf.writeCharCode(units[i]);
      i++;
    }
  }

  if (buf.isNotEmpty) {
    segments.add(StringSegment(buf.toString(), isAnsi: false));
  }

  return segments;
}

/// A segment of a string, either plain text or an ANSI escape sequence.
class StringSegment {
  final String text;
  final bool isAnsi;
  const StringSegment(this.text, {required this.isAnsi});
}
