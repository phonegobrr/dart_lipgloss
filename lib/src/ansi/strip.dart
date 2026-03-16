// Ported from charmbracelet/x/ansi
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Regex matching all ANSI escape sequences including CSI, OSC, and single-char escapes.
final _ansiPattern = RegExp(
  r'\x1B'
  r'(?:'
  r'[@-Z\\-_]' // Single-char escapes (Fe)
  r'|'
  r'\[[0-?]*[ -/]*[@-~]' // CSI sequences
  r'|'
  r'\].*?(?:\x07|\x1B\\)' // OSC sequences (terminated by BEL or ST)
  r')',
);

/// Strip all ANSI escape sequences from [s].
String stripAnsi(String s) => s.replaceAll(_ansiPattern, '');
