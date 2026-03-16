// Ported from charmbracelet/lipgloss/tree
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import '../style.dart';
import 'enumerator.dart';
import 'tree.dart';

/// Recursively render a tree to a string.
String renderTree(
  Tree tree,
  String prefix,
  EnumeratorFunc enumerator,
  IndenterFunc indenter,
  Style rootStyle,
  Style itemStyle,
  Style enumeratorStyle,
  Style indenterStyle,
  Style Function(List<Object> children, int i)? itemStyleFunc,
  Style Function(List<Object> children, int i)? enumeratorStyleFunc,
) {
  final buf = StringBuffer();
  final children = tree.getChildren();

  for (var i = 0; i < children.length; i++) {
    final child = children[i];

    // Get enumerator string
    final enumStr = enumerator(children, i);
    final styledEnum = enumeratorStyleFunc != null
        ? enumeratorStyleFunc(children, i).render(enumStr)
        : enumeratorStyle.render(enumStr);

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
    final styledContent = itemStyleFunc != null
        ? itemStyleFunc(children, i).render(content)
        : itemStyle.render(content);

    // Handle multi-line items
    final lines = styledContent.split('\n');
    final indentStr = indenter(children, i);

    buf.write(prefix);
    buf.write(styledEnum);
    buf.write(lines.first);

    // Additional lines of multi-line items
    for (var j = 1; j < lines.length; j++) {
      buf.write('\n');
      buf.write(prefix);
      final styledIndent = indenterStyle.render(indentStr);
      buf.write(styledIndent);
      buf.write(lines[j]);
    }

    // Render children if this is a subtree
    if (child is Tree && child.getChildren().isNotEmpty) {
      buf.write('\n');
      final childPrefix = prefix + indenterStyle.render(indentStr);
      buf.write(renderTree(
        child,
        childPrefix,
        enumerator,
        indenter,
        rootStyle,
        itemStyle,
        enumeratorStyle,
        indenterStyle,
        itemStyleFunc,
        enumeratorStyleFunc,
      ));
      // Newline before next sibling (if any)
      if (i < children.length - 1) {
        buf.write('\n');
      }
    } else if (i < children.length - 1) {
      buf.write('\n');
    }
  }

  return buf.toString();
}
