// Ported from charmbracelet/lipgloss/table
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import '../ansi/width.dart';
import '../border.dart';
import '../style.dart';
import '../wrap.dart' as wrap_lib;
import '../ansi/truncate.dart' as trunc;
import 'resizing.dart';
import 'rows.dart';

/// Constant for header row in StyleFunc.
const int headerRow = -1;

/// A styled, auto-resizing terminal table.
class Table {
  List<String> _headers = [];
  Data _data = StringData([]);
  Border _border = normalBorder;
  Style _borderStyle = const Style();
  Style _baseStyle = const Style();
  bool _borderRow = false;
  bool _borderColumn = false;
  bool _borderHeader = true;
  bool _borderTop = true;
  bool _borderBottom = true;
  bool _borderLeft = true;
  bool _borderRight = true;
  Style Function(int row, int col)? _styleFunc;
  int _width = 0;
  int _height = 0;
  int _yOffset = 0;
  bool _wrap = true;

  Table();

  /// Set header labels.
  Table headers(List<String> h) {
    _headers = h;
    return this;
  }

  /// Add a single row.
  Table row(List<String> r) {
    if (_data is StringData) {
      (_data as StringData).addRow(r);
    }
    return this;
  }

  /// Add multiple rows.
  Table rows(List<List<String>> r) {
    for (final row in r) {
      this.row(row);
    }
    return this;
  }

  /// Set data source.
  Table data(Data d) {
    _data = d;
    return this;
  }

  /// Get the data source.
  Data get getData => _data;

  /// Clear all rows.
  Table clearRows() {
    _data = StringData([]);
    return this;
  }

  /// Set the base style.
  Table baseStyle(Style s) {
    _baseStyle = s;
    return this;
  }

  /// Set the border style.
  Table borderDef(Border b) {
    _border = b;
    return this;
  }

  /// Set the ANSI style for the border.
  Table borderStyleDef(Style s) {
    _borderStyle = s;
    return this;
  }

  /// Show borders between rows.
  Table borderRow(bool v) {
    _borderRow = v;
    return this;
  }

  /// Show borders between columns.
  Table borderColumn(bool v) {
    _borderColumn = v;
    return this;
  }

  /// Show border between header and body.
  Table borderHeader(bool v) {
    _borderHeader = v;
    return this;
  }

  /// Show/hide specific border edges.
  Table borderEdges({bool? top, bool? bottom, bool? left, bool? right}) {
    if (top != null) _borderTop = top;
    if (bottom != null) _borderBottom = bottom;
    if (left != null) _borderLeft = left;
    if (right != null) _borderRight = right;
    return this;
  }

  /// Set a style function that returns a Style for each cell.
  /// Row -1 indicates the header row.
  Table styleFunc(Style Function(int row, int col) fn) {
    _styleFunc = fn;
    return this;
  }

  /// Set the total table width.
  Table tableWidth(int w) {
    _width = w;
    return this;
  }

  /// Set the table height.
  Table tableHeight(int h) {
    _height = h;
    return this;
  }

  /// Set the Y offset for scrolling.
  Table yOffset(int o) {
    _yOffset = o;
    return this;
  }

  /// Enable/disable word wrapping in cells.
  Table wrapContent(bool v) {
    _wrap = v;
    return this;
  }

  /// Render the table to a string.
  String render() {
    final numCols = _getNumColumns();
    if (numCols == 0) return '';

    final hasHeaders = _headers.isNotEmpty;
    final b = _border;

    // Build border styling
    String sb(String s) {
      if (s.isEmpty) return s;
      return _borderStyle.render(s);
    }

    // Measure content widths
    final contentWidths = <List<int>>[];
    if (hasHeaders) {
      final headerWidths = <int>[];
      for (var col = 0; col < numCols; col++) {
        headerWidths
            .add(col < _headers.length ? stringWidth(_headers[col]) : 0);
      }
      contentWidths.add(headerWidths);
    }
    for (var row = 0; row < _data.rows; row++) {
      final rowWidths = <int>[];
      for (var col = 0; col < numCols; col++) {
        rowWidths.add(stringWidth(_data.at(row, col)));
      }
      contentWidths.add(rowWidths);
    }

    // Calculate column widths
    final bw = b.left.isNotEmpty ? stringWidth(b.left) : 0;
    final colWidths = optimizedWidths(
      contentWidths,
      _width,
      numCols,
      _borderColumn,
      bw,
      hasLeftBorder: _borderLeft,
      hasRightBorder: _borderRight,
    );

    // If no target width, use natural widths
    final effectiveWidths =
        _width > 0 ? colWidths : _naturalWidths(contentWidths, numCols);

    final buf = StringBuffer();

    // Top border
    if (_borderTop && b.top.isNotEmpty) {
      buf.write(_renderTopBorder(effectiveWidths, b, sb));
      buf.write('\n');
    }

    // Header row
    if (hasHeaders) {
      buf.write(_renderRow(_headers, effectiveWidths, headerRow, b, sb));
      buf.write('\n');

      // Header separator
      if (_borderHeader && b.middle.isNotEmpty) {
        buf.write(_renderMiddleBorder(effectiveWidths, b, sb));
        buf.write('\n');
      }
    }

    // Data rows
    for (var i = 0; i < _data.rows; i++) {
      final rowCells = <String>[];
      for (var col = 0; col < numCols; col++) {
        rowCells.add(_data.at(i, col));
      }
      buf.write(_renderRow(rowCells, effectiveWidths, i, b, sb));
      if (i < _data.rows - 1) {
        buf.write('\n');
        if (_borderRow && b.middle.isNotEmpty) {
          buf.write(_renderMiddleBorder(effectiveWidths, b, sb));
          buf.write('\n');
        }
      }
    }

    // Bottom border
    if (_borderBottom && b.bottom.isNotEmpty) {
      buf.write('\n');
      buf.write(_renderBottomBorder(effectiveWidths, b, sb));
    }

    var result = buf.toString();

    // Apply height constraint with yOffset
    if (_height > 0 || _yOffset > 0) {
      final lines = result.split('\n');
      final start = _yOffset.clamp(0, lines.length);
      final end =
          _height > 0 ? (start + _height).clamp(0, lines.length) : lines.length;
      result = lines.sublist(start, end).join('\n');
    }

    return result;
  }

  int _getNumColumns() {
    var cols = _headers.length;
    if (_data.columns > cols) cols = _data.columns;
    return cols;
  }

  List<int> _naturalWidths(List<List<int>> contentWidths, int numCols) {
    final widths = List<int>.filled(numCols, 0);
    for (final rowWidths in contentWidths) {
      for (var col = 0; col < numCols && col < rowWidths.length; col++) {
        if (rowWidths[col] > widths[col]) {
          widths[col] = rowWidths[col];
        }
      }
    }
    return widths;
  }

  String _renderRow(
    List<String> cells,
    List<int> widths,
    int rowIdx,
    Border b,
    String Function(String) sb,
  ) {
    // Build styled cells for multi-line joining
    final styledCells = <String>[];

    for (var col = 0; col < widths.length; col++) {
      var cellContent = col < cells.length ? cells[col] : '';
      final width = widths[col];

      // Word wrap or truncate
      if (width > 0 && stringWidth(cellContent) > width) {
        if (_wrap) {
          cellContent = wrap_lib.wordWrap(cellContent, width);
        } else {
          cellContent = trunc.truncate(cellContent, width, '\u2026');
        }
      }

      // Apply style func (inheriting from base style)
      var styled = cellContent;
      if (_styleFunc != null) {
        final style = _styleFunc!(rowIdx, col).inherit(_baseStyle);
        styled = style.render(cellContent);
      } else if (_baseStyle != const Style()) {
        styled = _baseStyle.render(cellContent);
      }

      // Pad to width
      final cellWidth = stringWidth(styled);
      final padNeeded = width - cellWidth;
      if (padNeeded > 0) {
        styledCells.add(' $styled${' ' * padNeeded} ');
      } else {
        styledCells.add(' $styled ');
      }
    }

    // Use joinHorizontal for multi-line cells
    final hasMultiLine = styledCells.any((c) => c.contains('\n'));
    if (hasMultiLine) {
      return _renderMultiLineRow(styledCells, widths, b, sb);
    }

    // Single-line row
    final rowBuf = StringBuffer();
    if (_borderLeft) rowBuf.write(sb(b.left));

    for (var col = 0; col < styledCells.length; col++) {
      rowBuf.write(styledCells[col]);
      if (col < styledCells.length - 1 && _borderColumn) {
        rowBuf.write(sb(b.left));
      }
    }

    if (_borderRight) rowBuf.write(sb(b.right));
    return rowBuf.toString();
  }

  String _renderMultiLineRow(
    List<String> styledCells,
    List<int> widths,
    Border b,
    String Function(String) sb,
  ) {
    // Split each cell into lines and find max height
    final cellLines = <List<String>>[];
    var maxLines = 0;
    for (var col = 0; col < styledCells.length; col++) {
      final lines = styledCells[col].split('\n');
      cellLines.add(lines);
      if (lines.length > maxLines) maxLines = lines.length;
    }

    final rowBuf = StringBuffer();
    for (var lineIdx = 0; lineIdx < maxLines; lineIdx++) {
      if (_borderLeft) rowBuf.write(sb(b.left));

      for (var col = 0; col < cellLines.length; col++) {
        if (lineIdx < cellLines[col].length) {
          final line = cellLines[col][lineIdx];
          final lineW = stringWidth(line);
          // Pad to cell width (+2 for cell padding)
          final cellWidth = widths[col] + 2;
          final pad = cellWidth - lineW;
          rowBuf.write(line);
          if (pad > 0) rowBuf.write(' ' * pad);
        } else {
          // Empty line for shorter cells
          rowBuf.write(' ' * (widths[col] + 2));
        }

        if (col < cellLines.length - 1 && _borderColumn) {
          rowBuf.write(sb(b.left));
        }
      }

      if (_borderRight) rowBuf.write(sb(b.right));
      if (lineIdx < maxLines - 1) rowBuf.write('\n');
    }
    return rowBuf.toString();
  }

  String _renderTopBorder(
      List<int> widths, Border b, String Function(String) sb) {
    final buf = StringBuffer();
    if (_borderLeft) buf.write(sb(b.topLeft));

    for (var col = 0; col < widths.length; col++) {
      // +2 for cell padding (space on each side)
      final fillWidth = widths[col] + 2;
      buf.write(sb(b.top * fillWidth));
      if (col < widths.length - 1 && _borderColumn) {
        buf.write(sb(b.middleTop.isNotEmpty ? b.middleTop : b.top));
      }
    }

    if (_borderRight) buf.write(sb(b.topRight));
    return buf.toString();
  }

  String _renderMiddleBorder(
      List<int> widths, Border b, String Function(String) sb) {
    final buf = StringBuffer();
    if (_borderLeft) buf.write(sb(b.middleLeft));

    for (var col = 0; col < widths.length; col++) {
      final fillWidth = widths[col] + 2;
      // Use b.top for horizontal fill if available, otherwise default to '─'
      final fill = b.top.isNotEmpty ? b.top : '─';
      buf.write(sb(fill * fillWidth));
      if (col < widths.length - 1 && _borderColumn) {
        buf.write(sb(b.middle.isNotEmpty ? b.middle : fill));
      }
    }

    if (_borderRight) buf.write(sb(b.middleRight));
    return buf.toString();
  }

  String _renderBottomBorder(
      List<int> widths, Border b, String Function(String) sb) {
    final buf = StringBuffer();
    if (_borderLeft) buf.write(sb(b.bottomLeft));

    for (var col = 0; col < widths.length; col++) {
      final fillWidth = widths[col] + 2;
      buf.write(sb(b.bottom * fillWidth));
      if (col < widths.length - 1 && _borderColumn) {
        buf.write(sb(b.middleBottom.isNotEmpty ? b.middleBottom : b.bottom));
      }
    }

    if (_borderRight) buf.write(sb(b.bottomRight));
    return buf.toString();
  }

  @override
  String toString() => render();
}
