// Ported from charmbracelet/lipgloss canvas.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'ansi/sgr.dart';
import 'ansi/width.dart';

/// A single terminal cell.
class Cell {
  final String content;
  final AnsiStyle? style;
  const Cell(this.content, [this.style]);
}

/// A 2D cell buffer for compositing.
class Canvas {
  late List<List<Cell?>> _cells;
  int _width;
  int _height;

  Canvas(this._width, this._height) {
    _cells = List.generate(_height, (_) => List<Cell?>.filled(_width, null));
  }

  int get width => _width;
  int get height => _height;

  /// Place a multi-line string onto the canvas at position (x, y).
  void compose(int x, int y, String content) {
    final lines = content.split('\n');
    for (var row = 0; row < lines.length; row++) {
      final cy = y + row;
      if (cy < 0 || cy >= _height) continue;

      var cx = x;
      for (final rune in lines[row].runes) {
        final w = _runeDisplayWidth(rune);
        if (cx < 0) {
          cx += w;
          continue;
        }
        if (cx >= _width) break;

        final char = String.fromCharCode(rune);
        _cells[cy][cx] = Cell(char);
        // For wide characters, fill the next cell with null (occupied)
        for (var k = 1; k < w && cx + k < _width; k++) {
          _cells[cy][cx + k] = null;
        }
        cx += w;
      }
    }
  }

  /// Resize the canvas, preserving existing content.
  void resize(int newWidth, int newHeight) {
    final newCells = List.generate(
      newHeight,
      (row) => List<Cell?>.generate(
        newWidth,
        (col) {
          if (row < _height && col < _width) return _cells[row][col];
          return null;
        },
      ),
    );
    _cells = newCells;
    _width = newWidth;
    _height = newHeight;
  }

  /// Clear all cells.
  void clear() {
    for (var y = 0; y < _height; y++) {
      for (var x = 0; x < _width; x++) {
        _cells[y][x] = null;
      }
    }
  }

  /// Render the canvas to a string.
  String render() {
    final buf = StringBuffer();
    for (var y = 0; y < _height; y++) {
      for (var x = 0; x < _width; x++) {
        final cell = _cells[y][x];
        if (cell != null) {
          if (cell.style != null) {
            buf.write(cell.style!.styled(cell.content));
          } else {
            buf.write(cell.content);
          }
        } else {
          buf.write(' ');
        }
      }
      if (y < _height - 1) buf.write('\n');
    }
    return buf.toString();
  }
}

/// Get display width of a single rune.
int _runeDisplayWidth(int rune) => runeWidth(rune);
