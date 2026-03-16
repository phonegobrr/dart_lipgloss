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

  Tree.root(Object name) : _rootValue = name.toString();

  /// Add a child item. Item can be a String, Tree, or TreeLeaf.
  Tree child(Object item) {
    _children.add(item);
    return this;
  }

  /// Add multiple child items.
  Tree children(List<Object> items) {
    _children.addAll(items);
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

  /// Get the root value.
  String get rootValue => _rootValue;

  /// Get the children list.
  List<Object> getChildren() => List<Object>.unmodifiable(_children);

  /// Render the tree to a string.
  String render() {
    final buf = StringBuffer();

    // Render root
    buf.write(_rootStyle.render(_rootValue));

    if (_children.isNotEmpty) {
      buf.write('\n');
      buf.write(renderTree(
        this,
        '',
        _enumerator,
        _indenter,
        _rootStyle,
        _itemStyle,
        _enumeratorStyle,
        _indenterStyle,
        _itemStyleFunc,
        _enumeratorStyleFunc,
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
  const TreeLeaf(this.value);

  @override
  String toString() => value;
}
