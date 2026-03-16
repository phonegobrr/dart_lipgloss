// Dart-specific ergonomic extensions for dart_lipgloss.
// Not ported from Go — leverages Dart language features.

import 'ansi/sgr.dart';
import 'color.dart';
import 'style.dart';

/// Ergonomic extension methods for quick inline styling.
extension LipglossStringX on String {
  /// Render this string with the given Style.
  String styled(Style style) => style.render(this);

  /// Quick bold formatting.
  String lipBold() => Style().bold().render(this);

  /// Quick italic formatting.
  String lipItalic() => Style().italic().render(this);

  /// Quick faint formatting.
  String lipFaint() => Style().faint().render(this);

  /// Quick strikethrough formatting.
  String lipStrikethrough() => Style().strikethrough().render(this);

  /// Quick underline formatting.
  String lipUnderline() =>
      Style().underline(UnderlineStyle.single).render(this);

  /// Quick foreground color.
  String fg(String hex) => Style().foreground(lipColor(hex)).render(this);

  /// Quick background color.
  String bg(String hex) => Style().background(lipColor(hex)).render(this);

  /// Quick padding on all sides.
  String padded(int p) => Style().padding(p).render(this);
}
