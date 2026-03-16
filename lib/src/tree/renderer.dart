// Ported from charmbracelet/lipgloss/tree
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import '../ansi/width.dart';
import '../style.dart';
import 'enumerator.dart';
import 'tree.dart';

/// Bundles all renderer configuration for a tree.
class TreeRenderer {
  final EnumeratorFunc enumerator;
  final IndenterFunc indenter;
  final Style rootStyle;
  final Style itemStyle;
  final Style enumeratorStyle;
  final Style indenterStyle;
  final Style Function(List<Object> children, int i)? itemStyleFunc;
  final Style Function(List<Object> children, int i)? enumeratorStyleFunc;
  final Style Function(List<Object> children, int i)? indenterStyleFunc;

  const TreeRenderer({
    this.enumerator = defaultEnumerator,
    this.indenter = defaultIndenter,
    this.rootStyle = const Style(),
    this.itemStyle = const Style(),
    this.enumeratorStyle = const Style(),
    this.indenterStyle = const Style(),
    this.itemStyleFunc,
    this.enumeratorStyleFunc,
    this.indenterStyleFunc,
  });
}

/// Recursively render a tree to a string.
String renderTree(
  List<Object> children,
  String prefix,
  TreeRenderer r,
  int treeWidth,
) {
  final buf = StringBuffer();

  // Filter out hidden items
  final visibleChildren = <Object>[];
  for (final child in children) {
    if (child is Tree && child.hidden) continue;
    if (child is TreeLeaf && child.hidden) continue;
    visibleChildren.add(child);
  }

  if (visibleChildren.isEmpty) return '';

  // Calculate max enumerator width for alignment (4t)
  var maxEnumWidth = 0;
  for (var i = 0; i < visibleChildren.length; i++) {
    final enumStr = r.enumerator(visibleChildren, i);
    final w = stringWidth(enumStr);
    if (w > maxEnumWidth) maxEnumWidth = w;
  }

  for (var i = 0; i < visibleChildren.length; i++) {
    final child = visibleChildren[i];

    // Get enumerator string
    var enumStr = r.enumerator(visibleChildren, i);

    // Right-align enumerator to maxEnumWidth
    final enumW = stringWidth(enumStr);
    if (enumW < maxEnumWidth) {
      enumStr = '${' ' * (maxEnumWidth - enumW)}$enumStr';
    }

    final styledEnum = r.enumeratorStyleFunc != null
        ? r.enumeratorStyleFunc!(visibleChildren, i).render(enumStr)
        : r.enumeratorStyle.render(enumStr);

    // Get item content
    String content;
    if (child is Tree) {
      content = child.rootValue;
    } else if (child is TreeLeaf) {
      content = child.value;
    } else {
      content = child.toString();
    }

    // Apply item style
    final styledContent = r.itemStyleFunc != null
        ? r.itemStyleFunc!(visibleChildren, i).render(content)
        : r.itemStyle.render(content);

    // Handle multi-line items
    final lines = styledContent.split('\n');
    final indentStr = r.indenter(visibleChildren, i);

    // Right-align indent to match enumerator width
    var alignedIndent = indentStr;
    final indentW = stringWidth(indentStr);
    if (indentW < maxEnumWidth) {
      alignedIndent = '${' ' * (maxEnumWidth - indentW)}$indentStr';
    }

    String styledIndent;
    if (r.indenterStyleFunc != null) {
      styledIndent =
          r.indenterStyleFunc!(visibleChildren, i).render(alignedIndent);
    } else {
      styledIndent = r.indenterStyle.render(alignedIndent);
    }

    buf.write(prefix);
    buf.write(styledEnum);

    var firstLine = lines.first;
    if (treeWidth > 0) {
      final lineW = stringWidth('$prefix$styledEnum${lines.first}');
      if (lineW < treeWidth) {
        firstLine = '${lines.first}${' ' * (treeWidth - lineW)}';
      }
    }
    buf.write(firstLine);

    // Additional lines of multi-line items
    for (var j = 1; j < lines.length; j++) {
      buf.write('\n');
      buf.write(prefix);
      buf.write(styledIndent);
      var line = lines[j];
      if (treeWidth > 0) {
        final lineW = stringWidth('$prefix$styledIndent${lines[j]}');
        if (lineW < treeWidth) {
          line = '${lines[j]}${' ' * (treeWidth - lineW)}';
        }
      }
      buf.write(line);
    }

    // Render children if this is a subtree
    if (child is Tree && child.getChildren().isNotEmpty) {
      buf.write('\n');
      final childPrefix = prefix + styledIndent;

      // Use per-subtree renderer if available (4s)
      final childRenderer = child.customRenderer ?? r;

      buf.write(renderTree(
        child.getChildren(),
        childPrefix,
        childRenderer,
        treeWidth,
      ));
      // Newline before next sibling (if any)
      if (i < visibleChildren.length - 1) {
        buf.write('\n');
      }
    } else if (i < visibleChildren.length - 1) {
      buf.write('\n');
    }
  }

  return buf.toString();
}
