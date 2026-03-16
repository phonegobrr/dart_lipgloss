// Ported from charmbracelet/lipgloss/table
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import '../ansi/width.dart';
import '../ansi/sgr.dart';
import '../border.dart';
import '../color.dart';
import '../style.dart';
import 'resizing.dart';

/// Constant for header row in StyleFunc.
const int headerRow = -1;

/// A styled, auto-resizing terminal table.
class Table {
  List<String> _headers = [];
  final List<List<String>> _rows = [];
  Border _border = normalBorder;
  Style _borderStyle = const Style();
  bool _borderRow = false;
  bool _borderColumn = false;
  bool _borderHeader = true;
  bool _borderTop = true;
  bool _borderBottom = true;
  bool _borderLeft = true;
  bool _borderRight = true;
  Style Function(int row, int col)? _styleFunc;
  int _width = 0;
  // ignore: unused_field
  int _height = 0;
  // ignore: unused_field
  int _yOffset = 0;
  // ignore: unused_field
  bool _wrap = false;

  Table();

  /// Set header labels.
  Table headers(List<String> h) {
    _headers = h;
    return this;
  }

  /// Add a single row.
  Table row(List<String> r) {
    _rows.add(r);
    return this;
  }

  /// Add multiple rows.
  Table rows(List<List<String>> r) {
    _rows.addAll(r);
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
    final borderFg = _borderStyle.getForeground;
    final borderBg = _borderStyle.getBackground;
    final borderSgr = AnsiStyle();
    if (borderFg is! NoColor) borderSgr.setForeground(borderFg);
    if (borderBg is! NoColor) borderSgr.setBackground(borderBg);
    final hasBorderSgr = borderSgr.hasStyle;

    String sb(String s) => hasBorderSgr && s.isNotEmpty ? borderSgr.styled(s) : s;

    // Measure content widths
    final contentWidths = <List<int>>[];
    if (hasHeaders) {
      final headerWidths = <int>[];
      for (var col = 0; col < numCols; col++) {
        headerWidths.add(col < _headers.length ? stringWidth(_headers[col]) : 0);
      }
      contentWidths.add(headerWidths);
    }
    for (final row in _rows) {
      final rowWidths = <int>[];
      for (var col = 0; col < numCols; col++) {
        rowWidths.add(col < row.length ? stringWidth(row[col]) : 0);
      }
      contentWidths.add(rowWidths);
    }

    // Calculate column widths
    final colWidths = optimizedWidths(
      contentWidths,
      _width,
      numCols,
      _borderColumn,
      _borderLeft || _borderRight ? stringWidth(b.left) : 0,
    );

    // If no target width, use natural widths
    final effectiveWidths = _width > 0 ? colWidths : _naturalWidths(contentWidths, numCols);

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
    for (var i = 0; i < _rows.length; i++) {
      buf.write(_renderRow(_rows[i], effectiveWidths, i, b, sb));
      if (i < _rows.length - 1) {
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

    return buf.toString();
  }

  int _getNumColumns() {
    var cols = _headers.length;
    for (final row in _rows) {
      if (row.length > cols) cols = row.length;
    }
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
    final buf = StringBuffer();
    if (_borderLeft) buf.write(sb(b.left));

    for (var col = 0; col < widths.length; col++) {
      final cellContent = col < cells.length ? cells[col] : '';
      final width = widths[col];

      // Apply style func if set
      var styled = cellContent;
      if (_styleFunc != null) {
        final style = _styleFunc!(rowIdx, col);
        styled = style.render(cellContent);
      }

      // Pad to width
      final cellWidth = stringWidth(styled);
      final padNeeded = width - cellWidth;
      if (padNeeded > 0) {
        buf.write(' $styled${' ' * padNeeded} ');
      } else {
        buf.write(' $styled ');
      }

      if (col < widths.length - 1 && _borderColumn) {
        buf.write(sb(b.middle.isNotEmpty ? b.right : b.left));
      }
    }

    if (_borderRight) buf.write(sb(b.right));
    return buf.toString();
  }

  String _renderTopBorder(List<int> widths, Border b, String Function(String) sb) {
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

  String _renderMiddleBorder(List<int> widths, Border b, String Function(String) sb) {
    final buf = StringBuffer();
    if (_borderLeft) buf.write(sb(b.middleLeft));

    for (var col = 0; col < widths.length; col++) {
      final fillWidth = widths[col] + 2;
      final fill = b.middle.isNotEmpty ? b.top : '─';
      buf.write(sb(fill * fillWidth));
      if (col < widths.length - 1 && _borderColumn) {
        buf.write(sb(b.middle.isNotEmpty ? b.middle : fill));
      }
    }

    if (_borderRight) buf.write(sb(b.middleRight));
    return buf.toString();
  }

  String _renderBottomBorder(List<int> widths, Border b, String Function(String) sb) {
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
