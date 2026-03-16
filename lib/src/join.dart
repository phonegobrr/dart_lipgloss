// Ported from charmbracelet/lipgloss join.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'dart:math' as math;

import 'ansi/width.dart';

/// Join multi-line text blocks side-by-side with vertical alignment.
///
/// [pos] controls vertical alignment: 0.0 = top, 0.5 = center, 1.0 = bottom.
String joinHorizontal(double pos, List<String> strs) {
  if (strs.isEmpty) return '';
  if (strs.length == 1) return strs.first;

  // Split all strings into lines
  final blocks = strs.map((s) => s.split('\n')).toList();

  // Find max height
  var maxHeight = 0;
  for (final block in blocks) {
    if (block.length > maxHeight) maxHeight = block.length;
  }

  // Find widths of each block
  final widths = <int>[];
  for (final block in blocks) {
    var maxW = 0;
    for (final line in block) {
      final w = stringWidth(line);
      if (w > maxW) maxW = w;
    }
    widths.add(maxW);
  }

  // Pad blocks to same height using pos for vertical alignment
  final paddedBlocks = <List<String>>[];
  for (var i = 0; i < blocks.length; i++) {
    final block = blocks[i];
    final w = widths[i];
    final padCount = maxHeight - block.length;
    final topPad = (padCount * pos).round();
    final bottomPad = padCount - topPad;

    final padded = <String>[
      for (var j = 0; j < topPad; j++) ' ' * w,
      ...block,
      for (var j = 0; j < bottomPad; j++) ' ' * w,
    ];
    paddedBlocks.add(padded);
  }

  // Join lines from each block
  final result = StringBuffer();
  for (var row = 0; row < maxHeight; row++) {
    for (var col = 0; col < paddedBlocks.length; col++) {
      final line = paddedBlocks[col][row];
      final lineWidth = stringWidth(line);
      result.write(line);
      // Pad to block width if not last block
      if (col < paddedBlocks.length - 1) {
        final pad = widths[col] - lineWidth;
        if (pad > 0) result.write(' ' * pad);
      }
    }
    if (row < maxHeight - 1) result.write('\n');
  }

  return result.toString();
}

/// Stack multi-line text blocks vertically with horizontal alignment.
///
/// [pos] controls horizontal alignment: 0.0 = left, 0.5 = center, 1.0 = right.
String joinVertical(double pos, List<String> strs) {
  if (strs.isEmpty) return '';
  if (strs.length == 1) return strs.first;

  // Find max width across all blocks
  var maxWidth = 0;
  for (final s in strs) {
    for (final line in s.split('\n')) {
      final w = stringWidth(line);
      if (w > maxWidth) maxWidth = w;
    }
  }

  // Align each line within maxWidth
  final result = StringBuffer();
  var first = true;

  for (final s in strs) {
    final lines = s.split('\n');
    for (final line in lines) {
      if (!first) result.write('\n');
      first = false;

      final lineWidth = stringWidth(line);
      if (lineWidth >= maxWidth) {
        result.write(line);
      } else {
        final totalPad = maxWidth - lineWidth;
        final leftPad = (totalPad * pos).round();
        final rightPad = totalPad - leftPad;
        result.write(' ' * leftPad);
        result.write(line);
        result.write(' ' * rightPad);
      }
    }
  }

  return result.toString();
}
