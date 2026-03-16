// Ported from charmbracelet/lipgloss/table resizing.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'dart:math' as math;

import 'util.dart';

/// Calculate optimal column widths given content widths and constraints.
List<int> optimizedWidths(
  List<List<int>> contentWidths,
  int tableWidth,
  int numColumns,
  bool hasBorderColumn,
  int borderWidth, {
  bool hasLeftBorder = true,
  bool hasRightBorder = true,
}) {
  if (numColumns == 0) return [];

  // Calculate natural widths (max content width per column)
  final naturalWidths = List<int>.filled(numColumns, 0);
  for (final rowWidths in contentWidths) {
    for (var col = 0; col < numColumns && col < rowWidths.length; col++) {
      if (rowWidths[col] > naturalWidths[col]) {
        naturalWidths[col] = rowWidths[col];
      }
    }
  }

  if (tableWidth <= 0) return naturalWidths;

  // Calculate available width for content
  // Each cell has 1 space padding on each side (2 per cell)
  final cellPaddingOverhead = numColumns * 2;
  // Count outer borders only if they exist
  var borderOverhead = 0;
  if (hasLeftBorder) borderOverhead += borderWidth;
  if (hasRightBorder) borderOverhead += borderWidth;
  // Inner column separators
  if (hasBorderColumn && numColumns > 1) {
    borderOverhead += borderWidth * (numColumns - 1);
  }
  final availableWidth = tableWidth - borderOverhead - cellPaddingOverhead;

  if (availableWidth <= 0) return List<int>.filled(numColumns, 1);

  final totalNatural = sum(naturalWidths);

  if (totalNatural <= availableWidth) {
    // Expand to fill
    return _expandWidths(naturalWidths, availableWidth);
  } else {
    // Shrink to fit
    return _shrinkWidths(naturalWidths, contentWidths, availableWidth, numColumns);
  }
}

/// Expand columns proportionally to fill available width.
List<int> _expandWidths(List<int> widths, int available) {
  final total = sum(widths);
  if (total >= available) return widths;

  final result = List<int>.from(widths);
  var remaining = available - total;

  // Distribute evenly
  while (remaining > 0) {
    for (var i = 0; i < result.length && remaining > 0; i++) {
      result[i]++;
      remaining--;
    }
  }

  return result;
}

/// Shrink columns to fit, using median-based smart cropping.
List<int> _shrinkWidths(
  List<int> naturalWidths,
  List<List<int>> contentWidths,
  int available,
  int numColumns,
) {
  final result = List<int>.from(naturalWidths);
  var total = sum(result);

  // Iteratively shrink the widest column
  while (total > available) {
    // Find the widest column
    var widestIdx = 0;
    var widestVal = 0;
    for (var i = 0; i < result.length; i++) {
      if (result[i] > widestVal) {
        widestVal = result[i];
        widestIdx = i;
      }
    }

    if (result[widestIdx] <= 1) break;

    // Calculate median for this column
    final colWidths = <int>[];
    for (final rowWidths in contentWidths) {
      if (widestIdx < rowWidths.length) {
        colWidths.add(rowWidths[widestIdx]);
      }
    }

    final med = median(colWidths).ceil();
    final target = math.max(med, 1);
    final reduction = math.min(result[widestIdx] - target, total - available);

    if (reduction > 0) {
      result[widestIdx] -= reduction;
      total -= reduction;
    } else {
      result[widestIdx]--;
      total--;
    }
  }

  // Ensure minimum width of 1
  for (var i = 0; i < result.length; i++) {
    if (result[i] < 1) result[i] = 1;
  }

  return result;
}
