// Ported from charmbracelet/lipgloss/tree
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import '../style.dart';
import 'enumerator.dart';
import 'renderer.dart';

/// A tree for terminal rendering.
class Tree {
  String _rootValue;
  final List<Object> _children = [];
  EnumeratorFunc _enumerator = defaultEnumerator;
  IndenterFunc _indenter = defaultIndenter;
  Style _rootStyle = const Style();
  Style _itemStyle = const Style();
  Style _enumeratorStyle = const Style();
  Style _indenterStyle = const Style();
  Style Function(List<Object> children, int i)? _itemStyleFunc;
  Style Function(List<Object> children, int i)? _enumeratorStyleFunc;
  Style Function(List<Object> children, int i)? _indenterStyleFunc;
  bool _hidden = false;
  int _offsetStart = 0;
  int _offsetEnd = 0;
  int _width = 0;

  // Per-subtree custom renderer (4s)
  TreeRenderer? customRenderer;

  Tree.root(Object name) : _rootValue = name.toString();

  /// Set the root value.
  Tree root(Object r) {
    _rootValue = r.toString();
    return this;
  }

  /// Add a child item. Item can be a String, Tree, or TreeLeaf.
  /// When a subtree has no root value, auto-parent it to the previous sibling (4q).
  Tree child(Object item) {
    if (item is Tree && item._rootValue.isEmpty && _children.isNotEmpty) {
      // Auto-nest: attach as children of previous sibling
      final prev = _children.last;
      if (prev is Tree) {
        for (final c in item.getChildren()) {
          prev.child(c);
        }
        return this;
      }
    }
    _children.add(item);
    return this;
  }

  /// Add multiple child items.
  Tree children(List<Object> items) {
    for (final item in items) {
      child(item);
    }
    return this;
  }

  /// Set the enumerator function.
  Tree enumerator(EnumeratorFunc fn) {
    _enumerator = fn;
    return this;
  }

  /// Set the indenter function.
  Tree indenter(IndenterFunc fn) {
    _indenter = fn;
    return this;
  }

  /// Set the root label style.
  Tree rootStyle(Style s) {
    _rootStyle = s;
    return this;
  }

  /// Set the item style.
  Tree itemStyle(Style s) {
    _itemStyle = s;
    return this;
  }

  /// Set the enumerator style.
  Tree enumeratorStyle(Style s) {
    _enumeratorStyle = s;
    return this;
  }

  /// Set the indenter style.
  Tree indenterStyle(Style s) {
    _indenterStyle = s;
    return this;
  }

  /// Set a per-item style function.
  Tree itemStyleFunc(Style Function(List<Object> children, int i) fn) {
    _itemStyleFunc = fn;
    return this;
  }

  /// Set a per-item enumerator style function.
  Tree enumeratorStyleFunc(Style Function(List<Object> children, int i) fn) {
    _enumeratorStyleFunc = fn;
    return this;
  }

  /// Set a per-item indenter style function.
  Tree indenterStyleFunc(Style Function(List<Object> children, int i) fn) {
    _indenterStyleFunc = fn;
    return this;
  }

  /// Hide/show this tree node.
  Tree hide([bool v = true]) {
    _hidden = v;
    return this;
  }

  /// Whether this tree is hidden.
  bool get hidden => _hidden;

  /// Set offset for visible children (start, end).
  Tree offset(int start, int end) {
    _offsetStart = start;
    _offsetEnd = end;
    return this;
  }

  /// Set width for padding lines.
  Tree width(int w) {
    _width = w;
    return this;
  }

  /// Set a custom renderer for this subtree.
  Tree renderer(TreeRenderer r) {
    customRenderer = r;
    return this;
  }

  /// Get the root value.
  String get rootValue => _rootValue;

  /// Get the children list, applying offset.
  List<Object> getChildren() {
    if (_offsetStart == 0 && _offsetEnd == 0) {
      return List<Object>.unmodifiable(_children);
    }
    final end =
        (_children.length - _offsetEnd).clamp(_offsetStart, _children.length);
    if (_offsetStart >= end) return const [];
    return List<Object>.unmodifiable(_children.sublist(_offsetStart, end));
  }

  /// Get the raw children (no offset applied).
  List<Object> get rawChildren => List<Object>.unmodifiable(_children);

  /// Render the tree to a string.
  String render() {
    if (_hidden) return '';

    final buf = StringBuffer();

    // Render root
    buf.write(_rootStyle.render(_rootValue));

    final visibleChildren = getChildren();
    if (visibleChildren.isNotEmpty) {
      buf.write('\n');
      buf.write(renderTree(
        visibleChildren,
        '',
        customRenderer ??
            TreeRenderer(
              enumerator: _enumerator,
              indenter: _indenter,
              rootStyle: _rootStyle,
              itemStyle: _itemStyle,
              enumeratorStyle: _enumeratorStyle,
              indenterStyle: _indenterStyle,
              itemStyleFunc: _itemStyleFunc,
              enumeratorStyleFunc: _enumeratorStyleFunc,
              indenterStyleFunc: _indenterStyleFunc,
            ),
        _width,
      ));
    }

    return buf.toString();
  }

  @override
  String toString() => render();
}

/// A leaf node (no children).
class TreeLeaf {
  final String value;
  bool _hidden = false;

  TreeLeaf(this.value);

  /// Hide/show this leaf.
  TreeLeaf hide([bool v = true]) {
    _hidden = v;
    return this;
  }

  /// Whether this leaf is hidden.
  bool get hidden => _hidden;

  @override
  String toString() => value;
}
