// Ported from charmbracelet/lipgloss/table
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Data interface for table content.
abstract class Data {
  /// Get the value at [row], [cell].
  String at(int row, int cell);

  /// Number of rows.
  int get rows;

  /// Number of columns.
  int get columns;
}

/// Simple string-based Data implementation.
class StringData implements Data {
  final List<List<String>> _data;

  StringData(List<List<String>> data) : _data = List<List<String>>.from(data);

  /// Add a row.
  void addRow(List<String> row) {
    _data.add(row);
  }

  @override
  String at(int row, int cell) {
    if (row < 0 || row >= _data.length) return '';
    if (cell < 0 || cell >= _data[row].length) return '';
    return _data[row][cell];
  }

  @override
  int get rows => _data.length;

  @override
  int get columns => _data.isEmpty
      ? 0
      : _data.fold<int>(0, (max, row) {
          return row.length > max ? row.length : max;
        });
}

/// Filter wraps Data and shows only selected rows.
class Filter implements Data {
  final Data _data;
  final List<int> _indices;

  Filter(this._data, this._indices);

  @override
  String at(int row, int cell) {
    if (row < 0 || row >= _indices.length) return '';
    return _data.at(_indices[row], cell);
  }

  @override
  int get rows => _indices.length;

  @override
  int get columns => _data.columns;
}
