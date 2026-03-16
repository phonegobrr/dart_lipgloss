// Ported from charmbracelet/lipgloss layer.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'ansi/strip.dart';
import 'canvas.dart';
import 'size.dart' as sz;

/// A positioned layer for compositing.
class Layer {
  final String _id;
  final int _x;
  final int _y;
  final int _z;
  final String _content;
  final List<Layer> _children;

  Layer({
    String id = '',
    int x = 0,
    int y = 0,
    int z = 0,
    String content = '',
    List<Layer>? children,
  })  : _id = id,
        _x = x,
        _y = y,
        _z = z,
        _content = content,
        _children = children ?? [];

  String get id => _id;
  int get x => _x;
  int get y => _y;
  int get z => _z;
  String get content => _content;
  List<Layer> get children => List.unmodifiable(_children);

  Layer setX(int v) => Layer(id: _id, x: v, y: _y, z: _z, content: _content, children: _children);
  Layer setY(int v) => Layer(id: _id, x: _x, y: v, z: _z, content: _content, children: _children);
  Layer setZ(int v) => Layer(id: _id, x: _x, y: _y, z: v, content: _content, children: _children);
  Layer setId(String v) => Layer(id: v, x: _x, y: _y, z: _z, content: _content, children: _children);
  Layer setContent(String v) => Layer(id: _id, x: _x, y: _y, z: _z, content: v, children: _children);

  Layer addLayers(List<Layer> layers) => Layer(
        id: _id,
        x: _x,
        y: _y,
        z: _z,
        content: _content,
        children: [..._children, ...layers],
      );
}

/// Hit test result.
class LayerHit {
  final Layer layer;
  final int localX;
  final int localY;
  const LayerHit(this.layer, this.localX, this.localY);
}

/// Compositor resolves layer stack by z-index.
class Compositor {
  final List<Layer> _layers = [];

  void addLayers(List<Layer> layers) => _layers.addAll(layers);

  void addLayer(Layer layer) => _layers.add(layer);

  /// Render all layers onto a canvas.
  String render() {
    if (_layers.isEmpty) return '';

    // Flatten all layers (including children) and sort by z-index
    final allLayers = <Layer>[];
    _flattenLayers(_layers, allLayers);
    allLayers.sort((a, b) => a.z.compareTo(b.z));

    // Calculate canvas dimensions
    var maxWidth = 0;
    var maxHeight = 0;
    for (final layer in allLayers) {
      final w = layer.x + sz.getWidth(layer.content);
      final h = layer.y + sz.getHeight(layer.content);
      if (w > maxWidth) maxWidth = w;
      if (h > maxHeight) maxHeight = h;
    }

    if (maxWidth == 0 || maxHeight == 0) return '';

    // Compose layers onto canvas
    final canvas = Canvas(maxWidth, maxHeight);
    for (final layer in allLayers) {
      if (layer.content.isNotEmpty) {
        canvas.compose(layer.x, layer.y, stripAnsi(layer.content));
      }
    }

    return canvas.render();
  }

  /// Hit test: find the topmost layer at position (x, y).
  LayerHit? hit(int x, int y) {
    final allLayers = <Layer>[];
    _flattenLayers(_layers, allLayers);
    // Sort by z-index descending (topmost first)
    allLayers.sort((a, b) => b.z.compareTo(a.z));

    for (final layer in allLayers) {
      if (layer.content.isEmpty) continue;
      final lw = sz.getWidth(layer.content);
      final lh = sz.getHeight(layer.content);

      if (x >= layer.x &&
          x < layer.x + lw &&
          y >= layer.y &&
          y < layer.y + lh) {
        return LayerHit(layer, x - layer.x, y - layer.y);
      }
    }

    return null;
  }

  /// Get a layer by ID.
  Layer? getLayer(String id) {
    final allLayers = <Layer>[];
    _flattenLayers(_layers, allLayers);
    for (final layer in allLayers) {
      if (layer.id == id) return layer;
    }
    return null;
  }

  void _flattenLayers(List<Layer> layers, List<Layer> result) {
    for (final layer in layers) {
      result.add(layer);
      if (layer.children.isNotEmpty) {
        _flattenLayers(layer.children, result);
      }
    }
  }
}
