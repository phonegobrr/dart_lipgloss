// Ported from charmbracelet/lipgloss
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'dart:async';
import 'dart:io';

import 'color.dart';

/// Query the terminal background color via OSC 11.
/// Returns null if the terminal doesn't respond within [timeout].
Future<LipglossColor?> backgroundColor({
  Duration timeout = const Duration(seconds: 1),
}) async {
  if (!stdout.hasTerminal) return null;

  try {
    // Save terminal state
    final prevEcho = stdin.echoMode;
    final prevLine = stdin.lineMode;

    stdin.echoMode = false;
    stdin.lineMode = false;

    // Send OSC 11 query
    stdout.write('\x1b]11;?\x1b\\');

    try {
      final response = await _readTerminalResponse().timeout(timeout);
      return _parseOsc11Response(response);
    } on TimeoutException {
      return null;
    } finally {
      // Restore terminal state
      stdin.echoMode = prevEcho;
      stdin.lineMode = prevLine;
    }
  } catch (_) {
    return null;
  }
}

Future<String> _readTerminalResponse() async {
  final buf = StringBuffer();
  await for (final bytes in stdin) {
    for (final b in bytes) {
      buf.writeCharCode(b);
      // Look for ST (ESC \) or BEL
      final s = buf.toString();
      if (s.endsWith('\x1b\\') || s.endsWith('\x07')) {
        return s;
      }
    }
  }
  return buf.toString();
}

LipglossColor? _parseOsc11Response(String response) {
  // Expected: ESC ] 11 ; rgb:rr/gg/bb ST
  final match = RegExp(r'rgb:([0-9a-fA-F]+)/([0-9a-fA-F]+)/([0-9a-fA-F]+)')
      .firstMatch(response);
  if (match == null) return null;

  final r = _parseHexComponent(match.group(1)!);
  final g = _parseHexComponent(match.group(2)!);
  final b = _parseHexComponent(match.group(3)!);

  return RGBColor(r, g, b);
}

int _parseHexComponent(String hex) {
  final value = int.parse(hex, radix: 16);
  // Terminal may return 4-digit hex (0000-FFFF), normalize to 8-bit
  if (hex.length > 2) return value >> 8;
  return value;
}

/// Detect whether the terminal has a dark background.
Future<bool> hasDarkBackground({
  Duration timeout = const Duration(seconds: 1),
}) async {
  final bg = await backgroundColor(timeout: timeout);
  if (bg == null) return true; // default assumption
  return isDarkColor(bg);
}
