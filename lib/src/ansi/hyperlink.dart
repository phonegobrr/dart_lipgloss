// Ported from charmbracelet/x/ansi
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Generate an OSC 8 hyperlink opening sequence.
String setHyperlink(String url, [Map<String, String>? params]) {
  final paramStr =
      params?.entries.map((e) => '${e.key}=${e.value}').join(':') ?? '';
  return '\x1b]8;$paramStr;$url\x1b\\';
}

/// Generate an OSC 8 hyperlink closing sequence.
String resetHyperlink() => '\x1b]8;;\x1b\\';

/// Wrap [text] as a clickable hyperlink with [url].
String hyperlink(String url, String text) =>
    '${setHyperlink(url)}$text${resetHyperlink()}';
