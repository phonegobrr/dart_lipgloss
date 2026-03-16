# Porting Status

Maps upstream Lip Gloss (Go) features/files to Dart equivalents.

| Upstream File/Feature | Dart Equivalent | Status |
|---|---|---|
| `style.go` / `set.go` / `get.go` / `unset.go` | `lib/src/style.dart` | done |
| `color.go` | `lib/src/color.dart` | done |
| `borders.go` | `lib/src/border.dart` | done |
| `align.go` | `lib/src/align.dart` | done |
| `join.go` | `lib/src/join.dart` | done |
| `position.go` | `lib/src/position.dart` | done |
| `size.go` | `lib/src/size.dart` | done |
| `whitespace.go` | `lib/src/whitespace.dart` | done |
| `wrap.go` | `lib/src/wrap.dart` | done |
| `blending.go` | `lib/src/blending.dart` | done |
| `ranges.go` / `runes.go` | `lib/src/ranges.dart` | done |
| `writer.go` | `lib/src/writer.dart` | done |
| `canvas.go` / `layer.go` | `lib/src/canvas.dart`, `lib/src/layer.dart` | done |
| `table/` | `lib/src/table/` | done |
| `tree/` | `lib/src/tree/` | done |
| `list/` | `lib/src/list/` | done |
| `examples/layout/` | `example/layout.dart` | done |
| `examples/table/` | `example/table_*.dart` | done |
| `examples/tree/` | `example/tree_*.dart` | done |
| `examples/list/` | `example/list_*.dart` | done |
| `examples/blending/` | `example/blending_*.dart` | done |
| `examples/canvas/` | `example/canvas.dart` | done |

## Intentional Divergences from Upstream

| Area | Go Behavior | Dart Behavior | Reason |
|---|---|---|---|
| List class name | `list.List` | `LipglossList` | Avoids collision with Dart core `List` type |
| Color constructor | `lipgloss.Color("...")` | `lipColor("...")` | Avoids collision with `dart:ui` `Color` and Flutter |
| Print functions | `lipgloss.Println(...)` | `lipPrintln(...)` | Avoids collision with Dart built-in `print` |
| Functional options | `...WhitespaceOption` variadic | Named parameters | Idiomatic Dart |
| `sync.Once` | `sync.Once` struct | `late final` lazy initialization | Dart language feature |
| Goroutine+select+timeout | `go func()` + `select` + `time.After` | `Future.timeout()` | Dart async |
| value-type structs | Go struct copy semantics | Immutable class + copyWith | Dart has no value-type classes |
