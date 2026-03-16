// Ported from charmbracelet/lipgloss borders.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'package:meta/meta.dart';

import 'ansi/width.dart';

/// A border definition with characters for all edges and corners.
@immutable
class Border {
  final String top;
  final String bottom;
  final String left;
  final String right;
  final String topLeft;
  final String topRight;
  final String bottomLeft;
  final String bottomRight;
  final String middleLeft;
  final String middleRight;
  final String middle;
  final String middleTop;
  final String middleBottom;

  const Border({
    this.top = '',
    this.bottom = '',
    this.left = '',
    this.right = '',
    this.topLeft = '',
    this.topRight = '',
    this.bottomLeft = '',
    this.bottomRight = '',
    this.middleLeft = '',
    this.middleRight = '',
    this.middle = '',
    this.middleTop = '',
    this.middleBottom = '',
  });

  /// Whether this border has a visible top edge.
  int getTopSize() => top.isEmpty ? 0 : 1;

  /// Whether this border has a visible bottom edge.
  int getBottomSize() => bottom.isEmpty ? 0 : 1;

  /// The width of the left edge in terminal cells.
  int getLeftSize() => left.isEmpty ? 0 : stringWidth(left);

  /// The width of the right edge in terminal cells.
  int getRightSize() => right.isEmpty ? 0 : stringWidth(right);

  @override
  bool operator ==(Object other) =>
      other is Border &&
      top == other.top &&
      bottom == other.bottom &&
      left == other.left &&
      right == other.right &&
      topLeft == other.topLeft &&
      topRight == other.topRight &&
      bottomLeft == other.bottomLeft &&
      bottomRight == other.bottomRight &&
      middleLeft == other.middleLeft &&
      middleRight == other.middleRight &&
      middle == other.middle &&
      middleTop == other.middleTop &&
      middleBottom == other.middleBottom;

  @override
  int get hashCode => Object.hash(
        top,
        bottom,
        left,
        right,
        topLeft,
        topRight,
        bottomLeft,
        bottomRight,
        middleLeft,
        middleRight,
        middle,
        middleTop,
        middleBottom,
      );
}

// ─── Predefined borders ───

const noBorder = Border();

const normalBorder = Border(
  top: '─',
  bottom: '─',
  left: '│',
  right: '│',
  topLeft: '┌',
  topRight: '┐',
  bottomLeft: '└',
  bottomRight: '┘',
  middleLeft: '├',
  middleRight: '┤',
  middle: '┼',
  middleTop: '┬',
  middleBottom: '┴',
);

const roundedBorder = Border(
  top: '─',
  bottom: '─',
  left: '│',
  right: '│',
  topLeft: '╭',
  topRight: '╮',
  bottomLeft: '╰',
  bottomRight: '╯',
  middleLeft: '├',
  middleRight: '┤',
  middle: '┼',
  middleTop: '┬',
  middleBottom: '┴',
);

const thickBorder = Border(
  top: '━',
  bottom: '━',
  left: '┃',
  right: '┃',
  topLeft: '┏',
  topRight: '┓',
  bottomLeft: '┗',
  bottomRight: '┛',
  middleLeft: '┣',
  middleRight: '┫',
  middle: '╋',
  middleTop: '┳',
  middleBottom: '┻',
);

const doubleBorder = Border(
  top: '═',
  bottom: '═',
  left: '║',
  right: '║',
  topLeft: '╔',
  topRight: '╗',
  bottomLeft: '╚',
  bottomRight: '╝',
  middleLeft: '╠',
  middleRight: '╣',
  middle: '╬',
  middleTop: '╦',
  middleBottom: '╩',
);

const blockBorder = Border(
  top: '█',
  bottom: '█',
  left: '█',
  right: '█',
  topLeft: '█',
  topRight: '█',
  bottomLeft: '█',
  bottomRight: '█',
);

const outerHalfBlockBorder = Border(
  top: '▀',
  bottom: '▄',
  left: '▌',
  right: '▐',
  topLeft: '▛',
  topRight: '▜',
  bottomLeft: '▙',
  bottomRight: '▟',
);

const innerHalfBlockBorder = Border(
  top: '▄',
  bottom: '▀',
  left: '▐',
  right: '▌',
  topLeft: '▗',
  topRight: '▖',
  bottomLeft: '▝',
  bottomRight: '▘',
);

const hiddenBorder = Border(
  top: ' ',
  bottom: ' ',
  left: ' ',
  right: ' ',
  topLeft: ' ',
  topRight: ' ',
  bottomLeft: ' ',
  bottomRight: ' ',
);

const markdownBorder = Border(
  top: '-',
  bottom: '-',
  left: '|',
  right: '|',
  topLeft: '|',
  topRight: '|',
  bottomLeft: '|',
  bottomRight: '|',
  middleLeft: '|',
  middleRight: '|',
  middle: '|',
  middleTop: '|',
  middleBottom: '|',
);

const asciiBorder = Border(
  top: '-',
  bottom: '-',
  left: '|',
  right: '|',
  topLeft: '+',
  topRight: '+',
  bottomLeft: '+',
  bottomRight: '+',
  middleLeft: '+',
  middleRight: '+',
  middle: '+',
  middleTop: '+',
  middleBottom: '+',
);

// ─── Border rendering helpers ───

/// Render a horizontal border edge.
String renderHorizontalEdge(
    String leftCorner, String fill, String rightCorner, int width) {
  if (fill.isEmpty) return '';
  final fillWidth = stringWidth(fill);
  if (fillWidth == 0) return '';

  final leftW = stringWidth(leftCorner);
  final rightW = stringWidth(rightCorner);
  final innerWidth = width - leftW - rightW;
  if (innerWidth <= 0) return '$leftCorner$rightCorner';

  final repeatCount = innerWidth ~/ fillWidth;
  final remainder = innerWidth % fillWidth;
  final buf = StringBuffer(leftCorner);
  for (var i = 0; i < repeatCount; i++) {
    buf.write(fill);
  }
  if (remainder > 0) {
    buf.write(fill.substring(0, remainder.clamp(0, fill.length)));
  }
  buf.write(rightCorner);
  return buf.toString();
}
