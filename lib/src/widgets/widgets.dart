// Dart-specific composable widget layer for dart_lipgloss.
// Not ported from Go — provides Flutter-inspired composable API.

import '../border.dart';
import '../color.dart';
import '../join.dart';
import '../position.dart';
import '../style.dart';

/// Base widget interface for composable terminal UIs.
abstract class Widget {
  String render([int? maxWidth]);
}

/// Styled text widget.
class StyledText implements Widget {
  final String text;
  final Style style;
  const StyledText(this.text, {this.style = const Style()});

  @override
  String render([int? maxWidth]) => style.render(text);
}

/// Horizontal layout (like Flutter Row).
class Row implements Widget {
  final List<Widget> children;
  final double crossAxisAlignment;
  const Row({required this.children, this.crossAxisAlignment = posTop});

  @override
  String render([int? maxWidth]) => joinHorizontal(
        crossAxisAlignment,
        children.map((c) => c.render(maxWidth)).toList(),
      );
}

/// Vertical layout (like Flutter Column).
class Column implements Widget {
  final List<Widget> children;
  final double crossAxisAlignment;
  const Column({required this.children, this.crossAxisAlignment = posLeft});

  @override
  String render([int? maxWidth]) => joinVertical(
        crossAxisAlignment,
        children.map((c) => c.render(maxWidth)).toList(),
      );
}

/// Padding wrapper.
class Padded implements Widget {
  final Widget child;
  final int top;
  final int right;
  final int bottom;
  final int left;

  const Padded({
    required this.child,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  @override
  String render([int? maxWidth]) =>
      Style().padding(top, right, bottom, left).render(child.render(maxWidth));
}

/// Bordered wrapper.
class Bordered implements Widget {
  final Widget child;
  final Border borderType;
  final LipglossColor? borderColor;

  const Bordered({
    required this.child,
    this.borderType = roundedBorder,
    this.borderColor,
  });

  @override
  String render([int? maxWidth]) {
    var style = Style().border(borderType);
    if (borderColor != null) {
      style = style.borderForeground(borderColor!);
    }
    return style.render(child.render(maxWidth));
  }
}

/// Spacer widget that creates empty space.
class Spacer implements Widget {
  final int width;
  final int height;
  const Spacer({this.width = 1, this.height = 1});

  @override
  String render([int? maxWidth]) {
    final line = ' ' * width;
    return List.filled(height, line).join('\n');
  }
}
