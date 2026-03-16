// Ported from charmbracelet/lipgloss/tree
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Function that generates the enumerator prefix for a tree item.
typedef EnumeratorFunc = String Function(List<Object> children, int i);

/// Function that generates the indenter prefix for child items.
typedef IndenterFunc = String Function(List<Object> children, int i);

/// Default tree enumerator using box-drawing characters.
String defaultEnumerator(List<Object> children, int i) =>
    i == children.length - 1 ? '└── ' : '├── ';

/// Rounded tree enumerator using rounded box-drawing characters.
String roundedEnumerator(List<Object> children, int i) =>
    i == children.length - 1 ? '╰── ' : '├── ';

/// Default indenter for tree children.
String defaultIndenter(List<Object> children, int i) =>
    i == children.length - 1 ? '    ' : '│   ';

/// Rounded indenter for tree children.
String roundedIndenter(List<Object> children, int i) =>
    i == children.length - 1 ? '    ' : '│   ';
