// Ported from charmbracelet/x/ansi
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Regex matching all ANSI escape sequences including CSI, OSC, and single-char escapes.
final _ansiPattern = RegExp(
  // OSC sequences: ESC ] ... (BEL | ESC \)
  r'\x1B\].*?(?:\x07|\x1B\\)'
  r'|'
  // CSI sequences: ESC [ ... final byte
  r'\x1B\[[0-?]*[ -/]*[@-~]'
  r'|'
  // Single-char Fe escapes: ESC followed by a byte in 0x40-0x5F
  // (excluding [ and ] which are handled above)
  r'\x1B[@-Z^-_\\]',
);

/// Strip all ANSI escape sequences from [s].
String stripAnsi(String s) => s.replaceAll(_ansiPattern, '');
