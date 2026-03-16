// Ported from charmbracelet/lipgloss/list
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import '../ansi/width.dart';
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
  Style _indenterStyle = const Style();
  Style Function(List<Object> items, int i)? _itemStyleFunc;
  Style Function(List<Object> items, int i)? _indenterStyleFunc;
  bool _hidden = false;
  int _offsetStart = 0;
  int _offsetEnd = 0;

  LipglossList(List<Object> items) : _items = List<Object>.from(items);

  /// Add a single item.
  LipglossList item(Object item) {
    _items.add(item);
    return this;
  }

  /// Add multiple items.
  LipglossList items(List<Object> items) {
    _items.addAll(items);
    return this;
  }

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

  /// Set the indenter style.
  LipglossList indenterStyle(Style s) {
    _indenterStyle = s;
    return this;
  }

  /// Set a per-item style function.
  LipglossList itemStyleFunc(Style Function(List<Object> items, int i) fn) {
    _itemStyleFunc = fn;
    return this;
  }

  /// Set a per-item indenter style function.
  LipglossList indenterStyleFunc(Style Function(List<Object> items, int i) fn) {
    _indenterStyleFunc = fn;
    return this;
  }

  /// Hide/show this list.
  LipglossList hide([bool v = true]) {
    _hidden = v;
    return this;
  }

  /// Whether this list is hidden.
  bool get hidden => _hidden;

  /// Set offset for visible items.
  LipglossList offset(int start, int end) {
    _offsetStart = start;
    _offsetEnd = end;
    return this;
  }

  /// Get visible items (with offset applied).
  List<Object> _visibleItems() {
    if (_offsetStart == 0 && _offsetEnd == 0) return _items;
    final end = (_items.length - _offsetEnd).clamp(_offsetStart, _items.length);
    if (_offsetStart >= end) return const [];
    return _items.sublist(_offsetStart, end);
  }

  /// Render the list to a string.
  String render() {
    if (_hidden) return '';

    final items = _visibleItems();
    if (items.isEmpty) return '';

    final buf = StringBuffer();

    // Calculate max enumerator width for right-alignment (4y)
    var maxEnumWidth = 0;
    for (var i = 0; i < items.length; i++) {
      final enumStr = _enumerator(items, i);
      final w = stringWidth(enumStr);
      if (w > maxEnumWidth) maxEnumWidth = w;
    }

    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      // Get enumerator prefix
      var enumStr = _enumerator(items, i);

      // Right-align enumerator to maxEnumWidth
      final enumW = stringWidth(enumStr);
      if (enumW < maxEnumWidth) {
        enumStr = '${' ' * (maxEnumWidth - enumW)}$enumStr';
      }

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
          ? _itemStyleFunc!(items, i).render(content)
          : _itemStyle.render(content);

      // Handle multi-line items and nested lists
      final lines = styledContent.split('\n');

      // First line gets the enumerator
      buf.write(styledEnum);
      buf.write(lines.first);

      // Continuation lines get indentation matching enumerator width
      if (lines.length > 1) {
        final indentWidth = stringWidth(styledEnum);
        final indentStr = ' ' * indentWidth;

        // Apply indenter style
        String styledIndent;
        if (_indenterStyleFunc != null) {
          styledIndent = _indenterStyleFunc!(items, i).render(indentStr);
        } else {
          styledIndent = _indenterStyle.render(indentStr);
        }

        for (var j = 1; j < lines.length; j++) {
          buf.write('\n');
          // For nested lists, apply parent's indent to each line
          if (item is LipglossList) {
            buf.write(styledIndent);
          } else {
            buf.write(styledIndent);
          }
          buf.write(lines[j]);
        }
      }

      if (i < items.length - 1) buf.write('\n');
    }

    return buf.toString();
  }

  @override
  String toString() => render();
}
