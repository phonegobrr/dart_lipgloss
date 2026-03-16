// Ported from charmbracelet/lipgloss/tree
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Abstract children interface for tree items.
abstract class Children {
  int get length;
  Object at(int i);
  List<Object> toList();
}

/// Children backed by a list of objects.
class NodeChildren implements Children {
  final List<Object> _items;
  NodeChildren(this._items);

  @override
  int get length => _items.length;

  @override
  Object at(int i) => _items[i];

  @override
  List<Object> toList() => List<Object>.from(_items);
}

/// Filter wraps Children and shows only items matching a predicate.
class TreeFilter implements Children {
  final Children _children;
  final bool Function(int index) _predicate;
  late final List<int> _indices;

  TreeFilter(this._children, this._predicate) {
    _indices = <int>[];
    for (var i = 0; i < _children.length; i++) {
      if (_predicate(i)) _indices.add(i);
    }
  }

  @override
  int get length => _indices.length;

  @override
  Object at(int i) => _children.at(_indices[i]);

  @override
  List<Object> toList() => _indices.map((i) => _children.at(i)).toList();
}
