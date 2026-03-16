// Ported from charmbracelet/lipgloss/table
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'dart:math' as math;

import '../ansi/truncate.dart' as trunc;
import '../ansi/width.dart';
import '../border.dart';
import '../style.dart';
import '../wrap.dart' as wrap_lib;
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

  // Row-aware visibility (4e/4j)
  int _firstVisibleRowIndex = 0;
  int _lastVisibleRowIndex = -1;

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

  /// Set the table height (in rendered lines).
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

  // ─── Visibility getters (4j) ───

  /// The first visible data row index after height/yOffset are applied.
  int get firstVisibleRowIndex => _firstVisibleRowIndex;

  /// The last visible data row index after height/yOffset are applied.
  int get lastVisibleRowIndex => _lastVisibleRowIndex;

  /// The number of visible data rows.
  int get visibleRows => _lastVisibleRowIndex >= _firstVisibleRowIndex
      ? _lastVisibleRowIndex - _firstVisibleRowIndex + 1
      : 0;

  /// Render the table to a string.
  String render() {
    final numCols = _getNumColumns();
    if (numCols == 0) return '';

    final hasHeaders = _headers.isNotEmpty;
    final b = _border;

    // Build border styling using _borderStyle.render() (4i)
    String sb(String s) {
      if (s.isEmpty) return s;
      return _borderStyle.render(s);
    }

    // Measure content widths, accounting for styleFunc padding/border overhead
    final contentWidths = <List<int>>[];
    if (hasHeaders) {
      final headerWidths = <int>[];
      for (var col = 0; col < numCols; col++) {
        var w = col < _headers.length ? stringWidth(_headers[col]) : 0;
        if (_styleFunc != null) {
          final style = _styleFunc!(headerRow, col).inherit(_baseStyle);
          w += style.getHorizontalPadding + style.getHorizontalBorderSize;
        }
        headerWidths.add(w);
      }
      contentWidths.add(headerWidths);
    }
    for (var row = 0; row < _data.rows; row++) {
      final rowWidths = <int>[];
      for (var col = 0; col < numCols; col++) {
        var w = stringWidth(_data.at(row, col));
        if (_styleFunc != null) {
          final style = _styleFunc!(row, col).inherit(_baseStyle);
          w += style.getHorizontalPadding + style.getHorizontalBorderSize;
        }
        rowWidths.add(w);
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

    // ─── Row-aware height/yOffset rendering (4e) ───
    // Build all rendered row strings first, then apply visibility
    final renderedRows = <String>[];
    final rowSeparator = (_borderRow && b.middle.isNotEmpty)
        ? _renderMiddleBorder(effectiveWidths, b, sb)
        : null;

    // Header
    String? headerStr;
    String? headerSepStr;
    if (hasHeaders) {
      headerStr = _renderRow(_headers, effectiveWidths, headerRow, b, sb);
      if (_borderHeader && b.middle.isNotEmpty) {
        headerSepStr = _renderMiddleBorder(effectiveWidths, b, sb);
      }
    }

    // Data rows
    for (var i = 0; i < _data.rows; i++) {
      final rowCells = <String>[];
      for (var col = 0; col < numCols; col++) {
        rowCells.add(_data.at(i, col));
      }
      renderedRows.add(_renderRow(rowCells, effectiveWidths, i, b, sb));
    }

    // Determine visible row range based on yOffset and height
    _firstVisibleRowIndex = _yOffset.clamp(0, _data.rows);
    _lastVisibleRowIndex = _data.rows > 0 ? _data.rows - 1 : -1;

    if (_height > 0) {
      // Calculate how many lines borders/header take
      var fixedLines = 0;
      if (_borderTop && b.top.isNotEmpty) fixedLines++;
      if (hasHeaders) {
        fixedLines += headerStr!.split('\n').length;
        if (headerSepStr != null) fixedLines++;
      }
      if (_borderBottom && b.bottom.isNotEmpty) fixedLines++;

      // Available lines for data rows (reserve 1 for overflow indicator if needed)
      var availableForRows = _height - fixedLines;

      // Try to fit rows; if not all fit, we need 1 line for overflow indicator
      var lastVisible = _firstVisibleRowIndex - 1;
      var usedLines = 0;
      var allFit = true;
      if (availableForRows > 0) {
        for (var i = _firstVisibleRowIndex; i < renderedRows.length; i++) {
          final rowLines = renderedRows[i].split('\n').length;
          final separatorLines =
              (i > _firstVisibleRowIndex && rowSeparator != null) ? 1 : 0;
          if (usedLines + rowLines + separatorLines > availableForRows) {
            allFit = false;
            break;
          }
          usedLines += rowLines + separatorLines;
          lastVisible = i;
        }

        // If not all rows fit, re-run with 1 line reserved for overflow
        if (!allFit && availableForRows > 1) {
          availableForRows -= 1; // reserve for overflow row
          lastVisible = _firstVisibleRowIndex - 1;
          usedLines = 0;
          for (var i = _firstVisibleRowIndex; i < renderedRows.length; i++) {
            final rowLines = renderedRows[i].split('\n').length;
            final separatorLines =
                (i > _firstVisibleRowIndex && rowSeparator != null) ? 1 : 0;
            if (usedLines + rowLines + separatorLines > availableForRows) break;
            usedLines += rowLines + separatorLines;
            lastVisible = i;
          }
        }
        _lastVisibleRowIndex = lastVisible;
      } else {
        _lastVisibleRowIndex = _firstVisibleRowIndex - 1;
      }
    }

    // Build final output
    final buf = StringBuffer();

    // Top border
    if (_borderTop && b.top.isNotEmpty) {
      buf.write(_renderTopBorder(effectiveWidths, b, sb));
      buf.write('\n');
    }

    // Header
    if (headerStr != null) {
      buf.write(headerStr);
      buf.write('\n');
      if (headerSepStr != null) {
        buf.write(headerSepStr);
        buf.write('\n');
      }
    }

    // Visible data rows
    for (var i = _firstVisibleRowIndex;
        i <= _lastVisibleRowIndex && i < renderedRows.length;
        i++) {
      if (i > _firstVisibleRowIndex && rowSeparator != null) {
        buf.write(rowSeparator);
        buf.write('\n');
      }
      buf.write(renderedRows[i]);
      if (i < _lastVisibleRowIndex || (_borderBottom && b.bottom.isNotEmpty)) {
        buf.write('\n');
      }
    }

    // Overflow indicator
    if (_height > 0 && _lastVisibleRowIndex < _data.rows - 1) {
      final overflowCount = _data.rows - 1 - _lastVisibleRowIndex;
      final overflowLabel = ' \u2026 $overflowCount more';
      final labelWidth = stringWidth(overflowLabel);
      // Total content area width (cell widths + padding + column separators)
      final totalContentW = effectiveWidths.fold(0, (a, b) => a + b) +
          effectiveWidths.length * 2 +
          (_borderColumn ? math.max(0, effectiveWidths.length - 1) * bw : 0);
      final padNeeded = totalContentW - labelWidth;

      if (_borderLeft) buf.write(sb(b.left));
      buf.write(overflowLabel);
      if (padNeeded > 0) buf.write(' ' * padNeeded);
      if (_borderRight) buf.write(sb(b.right));
      buf.write('\n');
    }

    // Bottom border
    if (_borderBottom && b.bottom.isNotEmpty) {
      buf.write(_renderBottomBorder(effectiveWidths, b, sb));
    }

    return buf.toString();
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

    // Use multi-line rendering for multi-line cells
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
