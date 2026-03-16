# Dart Lip Gloss

**A native Dart port of [Lip Gloss](https://github.com/charmbracelet/lipgloss) by [Charmbracelet](https://charm.sh).**

> Style definitions for nice terminal layouts. Built with TUIs in mind.

This is an independent, native Dart port of the Go Lip Gloss library (MIT licensed). It is **not a fork** and is **not affiliated with Charmbracelet, Inc.**

All credit for the original design, API concepts, and inspiration belongs to the Charmbracelet team.

## Installation

```sh
dart pub add dart_lipgloss
```

## Quick Start

```dart
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  final style = Style()
      .bold()
      .foreground(lipColor('#FAFAFA'))
      .background(lipColor('#7D56F4'))
      .paddingTop(2)
      .paddingLeft(4)
      .width(22);

  print(style.render('Hello, Lip Gloss'));
}
```

## Demo Binary

```sh
# Run directly
dart run bin/demo.dart

# Compile to native executable
dart compile exe bin/demo.dart -o build/dart_lipgloss_demo
./build/dart_lipgloss_demo
```

## Features

- Inline formatting: bold, italic, faint, blink, strikethrough, underline (single/double/curly/dotted/dashed), reverse
- Colors: ANSI 16, ANSI 256, TrueColor (hex), adaptive light/dark
- Borders: normal, rounded, thick, double, block, outer/inner half-block, hidden, markdown, ASCII
- Layout: padding, margins, alignment, width/height constraints, max width/height
- Compositing: joinHorizontal, joinVertical, place, placeHorizontal, placeVertical
- Tables: auto-resizing columns, style functions, header/row/cell borders
- Lists: bullet, arabic, roman, alphabet, dash, asterisk, custom enumerators, nesting
- Trees: recursive rendering, rounded/default enumerators, custom indentation
- Color blending: 1D and 2D gradients via CIELAB interpolation
- Canvas/Compositor: cell-buffer layering with x/y/z positioning and hit testing
- Hyperlinks: OSC 8 terminal hyperlink support
- Terminal detection: color profile auto-detection and color downsampling

## Credits & Acknowledgements

This project is a native Dart port of [Lip Gloss](https://github.com/charmbracelet/lipgloss) by [Charmbracelet, Inc.](https://charm.sh), released under the [MIT License](https://github.com/charmbracelet/lipgloss/blob/master/LICENSE).

We are deeply grateful to the Charmbracelet team for creating such an excellent library.

## License

MIT - see [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
