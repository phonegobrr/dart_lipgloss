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

/// Sentinel cell marking a position occupied by a wide character's trailing column.
const _wideCharContinuation = Cell('');

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
  /// Handles ANSI escape sequences by skipping them for width measurement
  /// but preserving them in cell content.
  void compose(int x, int y, String content) {
    final lines = content.split('\n');
    for (var row = 0; row < lines.length; row++) {
      final cy = y + row;
      if (cy < 0 || cy >= _height) continue;

      var cx = x;
      final line = lines[row];
      final codeUnits = line.codeUnits;
      var i = 0;

      // Buffer to accumulate ANSI sequences before the next visible char
      final ansiBuf = StringBuffer();

      while (i < codeUnits.length) {
        // Check for ESC sequence
        if (codeUnits[i] == 0x1B && i + 1 < codeUnits.length) {
          final next = codeUnits[i + 1];
          if (next == 0x5B) {
            // CSI sequence: ESC [ ... final_byte
            final start = i;
            i += 2;
            while (i < codeUnits.length && codeUnits[i] < 0x40) {
              i++;
            }
            if (i < codeUnits.length) i++; // skip final byte
            ansiBuf.write(String.fromCharCodes(codeUnits.sublist(start, i)));
          } else if (next == 0x5D) {
            // OSC sequence: ESC ] ... (BEL | ESC \)
            final start = i;
            i += 2;
            while (i < codeUnits.length) {
              if (codeUnits[i] == 0x07) {
                i++;
                break;
              }
              if (codeUnits[i] == 0x1B &&
                  i + 1 < codeUnits.length &&
                  codeUnits[i + 1] == 0x5C) {
                i += 2;
                break;
              }
              i++;
            }
            ansiBuf.write(String.fromCharCodes(codeUnits.sublist(start, i)));
          } else {
            ansiBuf.writeCharCode(codeUnits[i]);
            ansiBuf.writeCharCode(codeUnits[i + 1]);
            i += 2;
          }
          continue;
        }

        // Regular character
        int codePoint;
        int consumed;
        if (codeUnits[i] >= 0xD800 &&
            codeUnits[i] <= 0xDBFF &&
            i + 1 < codeUnits.length) {
          codePoint = 0x10000 +
              ((codeUnits[i] - 0xD800) << 10) +
              (codeUnits[i + 1] - 0xDC00);
          consumed = 2;
        } else {
          codePoint = codeUnits[i];
          consumed = 1;
        }

        final w = _runeDisplayWidth(codePoint);
        if (cx < 0) {
          cx += w;
          i += consumed;
          ansiBuf.clear();
          continue;
        }
        if (cx >= _width) break;

        // Build cell content: any preceding ANSI sequences + the character
        final char = String.fromCharCode(codePoint);
        String cellContent;
        if (ansiBuf.isNotEmpty) {
          cellContent = '${ansiBuf.toString()}$char';
          ansiBuf.clear();
        } else {
          cellContent = char;
        }

        _cells[cy][cx] = Cell(cellContent);
        // For wide characters, mark continuation cells
        for (var k = 1; k < w && cx + k < _width; k++) {
          _cells[cy][cx + k] = _wideCharContinuation;
        }
        cx += w;
        i += consumed;
      }

      // If there are trailing ANSI sequences (like reset), attach to last cell
      if (ansiBuf.isNotEmpty && cx > x && cx - 1 < _width) {
        final lastCx = cx - 1;
        final lastCell = _cells[cy][lastCx];
        if (lastCell != null && !identical(lastCell, _wideCharContinuation)) {
          _cells[cy][lastCx] = Cell('${lastCell.content}${ansiBuf.toString()}');
        }
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
          if (identical(cell, _wideCharContinuation)) {
            // Skip: this cell is occupied by the trailing column of a wide char
            continue;
          }
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
