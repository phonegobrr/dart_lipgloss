// Ported from charmbracelet/lipgloss/list
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import '../style.dart';
import 'enumerator.dart';

/// A styled list for terminal rendering.
///
/// Named LipglossList to avoid collision with Dart's core List<T> type.
class LipglossList {
  final List<Object> _items;
  ListEnumeratorFunc _enumerator = bullet;
  Style _itemStyle = const Style();
  Style _enumeratorStyle = const Style();
  Style Function(List<Object> items, int i)? _itemStyleFunc;

  LipglossList(this._items);

  /// Set the enumerator function.
  LipglossList enumerator(ListEnumeratorFunc fn) {
    _enumerator = fn;
    return this;
  }

  /// Set the item style.
  LipglossList itemStyle(Style s) {
    _itemStyle = s;
    return this;
  }

  /// Set the enumerator style.
  LipglossList enumeratorStyle(Style s) {
    _enumeratorStyle = s;
    return this;
  }

  /// Set a per-item style function.
  LipglossList itemStyleFunc(Style Function(List<Object> items, int i) fn) {
    _itemStyleFunc = fn;
    return this;
  }

  /// Render the list to a string.
  String render() {
    if (_items.isEmpty) return '';

    final buf = StringBuffer();
    final enum_ = _enumerator;

    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];

      // Get enumerator prefix
      final enumStr = enum_(_items, i);
      final styledEnum = _enumeratorStyle.render(enumStr);

      // Get item content
      String content;
      if (item is LipglossList) {
        content = item.render();
      } else {
        content = item.toString();
      }

      // Apply item style
      final styledContent = _itemStyleFunc != null
          ? _itemStyleFunc!(_items, i).render(content)
          : _itemStyle.render(content);

      // Handle multi-line items
      final lines = styledContent.split('\n');
      buf.write(styledEnum);
      buf.write(lines.first);

      // Indent continuation lines
      if (lines.length > 1) {
        final indent = ' ' * _enumWidth(enumStr);
        for (var j = 1; j < lines.length; j++) {
          buf.write('\n');
          buf.write(indent);
          buf.write(lines[j]);
        }
      }

      if (i < _items.length - 1) buf.write('\n');
    }

    return buf.toString();
  }

  int _enumWidth(String enumStr) {
    // Simple visible width calculation for indentation
    var w = 0;
    for (final r in enumStr.runes) {
      if (r >= 0x20) w++; // Skip control chars
    }
    return w;
  }

  @override
  String toString() => render();
}
