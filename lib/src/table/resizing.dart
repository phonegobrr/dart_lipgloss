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
    // Shrink to fit using three-phase algorithm
    return _shrinkWidthsThreePhase(
        naturalWidths, contentWidths, availableWidth, numColumns);
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

/// Three-phase shrink algorithm matching Go lipgloss v2:
/// Phase 1: shrinkBiggestColumns(veryBigOnly=true) - only shrink columns > 2x median
/// Phase 2: shrinkToMedian() - shrink widest column to its median
/// Phase 3: shrinkBiggestColumns(veryBigOnly=false) - shrink any widest column by 1
List<int> _shrinkWidthsThreePhase(
  List<int> naturalWidths,
  List<List<int>> contentWidths,
  int available,
  int numColumns,
) {
  final result = List<int>.from(naturalWidths);
  var total = sum(result);

  // Phase 1: Shrink very big columns (> 2x median of their content)
  var madeProgress = true;
  while (total > available && madeProgress) {
    madeProgress = false;
    for (var col = 0; col < result.length; col++) {
      if (total <= available) break;
      if (result[col] <= 1) continue;

      final med = _columnMedian(contentWidths, col);
      // "Very big" means > 2x median
      if (result[col] <= med * 2) continue;

      final target = math.max(med * 2, 1);
      final reduction = math.min(result[col] - target, total - available);
      if (reduction <= 0) continue;

      result[col] -= reduction;
      total -= reduction;
      madeProgress = true;
    }
  }

  // Phase 2: Shrink to median
  while (total > available) {
    final widestIdx = _findWidest(result);
    if (result[widestIdx] <= 1) break;

    final med = _columnMedian(contentWidths, widestIdx);
    final target = math.max(med, 1);
    final reduction = math.min(result[widestIdx] - target, total - available);

    if (reduction > 0) {
      result[widestIdx] -= reduction;
      total -= reduction;
    } else {
      // Phase 3: Shrink widest by 1
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

int _findWidest(List<int> widths) {
  var widestIdx = 0;
  var widestVal = 0;
  for (var i = 0; i < widths.length; i++) {
    if (widths[i] > widestVal) {
      widestVal = widths[i];
      widestIdx = i;
    }
  }
  return widestIdx;
}

int _columnMedian(List<List<int>> contentWidths, int col) {
  final colWidths = <int>[];
  for (final rowWidths in contentWidths) {
    if (col < rowWidths.length) {
      colWidths.add(rowWidths[col]);
    }
  }
  return median(colWidths).ceil();
}
