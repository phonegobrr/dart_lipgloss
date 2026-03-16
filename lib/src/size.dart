// Ported from charmbracelet/lipgloss size.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'dart:math' as math;

import 'ansi/width.dart';

/// Get the visible width of the widest line in [s].
int getWidth(String s) {
  if (s.isEmpty) return 0;
  final lines = s.split('\n');
  var maxW = 0;
  for (final line in lines) {
    final w = stringWidth(line);
    if (w > maxW) maxW = w;
  }
  return maxW;
}

/// Get the number of lines in [s].
int getHeight(String s) {
  if (s.isEmpty) return 0;
  return s.split('\n').length;
}

/// Get (width, height) as a record.
(int, int) getSize(String s) => (getWidth(s), getHeight(s));
