# dart_lipgloss Parity Manifest

Tracks parity with Go [lipgloss v2](https://github.com/charmbracelet/lipgloss).
Every upstream public feature is listed with its status.

**Legend:** Implemented | Intentionally Omitted (reason) | TODO (tracking)

---

## Core Style Engine

| Feature | Status |
|---------|--------|
| Style immutable builder pattern | Implemented |
| Props bitfield tracking | Implemented (JS-safe two-integer) |
| Bold/Italic/Faint/Blink/Reverse/Strikethrough | Implemented |
| UnderlineStyle (none/single/double/curly/dotted/dashed) | Implemented |
| UnderlineColor | Implemented |
| Foreground/Background colors | Implemented |
| MarginBackground | Implemented |
| Width/Height/MaxWidth/MaxHeight | Implemented |
| Padding (CSS shorthand + per-side) | Implemented |
| Margin (CSS shorthand + per-side) | Implemented |
| PaddingChar/MarginChar | Implemented |
| Align (horizontal/vertical) | Implemented |
| Border (style + per-side enable) | Implemented |
| Border shorthand (CSS-like 1-4 args) | Implemented |
| Per-side border foreground/background | Implemented |
| Border foreground blend (gradient) | Implemented |
| Border foreground blend offset | Implemented |
| Inline mode | Implemented (inline()) |
| TabWidth (incl. 0=remove, -1=preserve) | Implemented |
| UnderlineSpaces/StrikethroughSpaces | Implemented |
| ColorWhitespace | Implemented |
| Transform function | Implemented |
| Hyperlink (OSC 8) with params | Implemented |
| SetString (variadic join) | Implemented |
| UnsetString | Implemented |
| NBSP constant | Implemented |
| Render (variadic join, prepend value) | Implemented |
| Inherit (formatting/colors only, not layout) | Implemented |
| inherit() bg→marginBg propagation | Implemented |
| inherit() does NOT inherit padding/margins | Implemented |
| borderStyle alone auto-enables all sides | Implemented |
| Empty border corners fill with space | Implemented |
| Frame size includes margins+padding+borders | Implemented |
| Horizontal alignment subtracts only borders | Implemented |
| Alignment triggered on width/multiline | Implemented |
| Horizontal alignment before vertical (pipeline order) | Implemented |
| Height adjusted for border size | Implemented |
| Height is minimum, not crop | Implemented |
| Inline skips wrap/padding/border/margin | Implemented |
| Three-style text styling (te/teSpace/teWhitespace) | Implemented |
| ColorWhitespace passed to alignment fill | Implemented |
| underlineBool() convenience | Implemented |

## Color System

| Feature | Status |
|---------|--------|
| NoColor/ANSIColor/ANSI256Color/RGBColor | Implemented |
| Color parsing (hex, ANSI index) | Implemented |
| Complementary (HSV hue rotation) | Implemented |
| Alpha (preserves RGB) | Implemented |
| Darken/Lighten | Implemented |
| IsDarkColor | Implemented |
| AdaptiveColor | Implemented |
| CompleteAdaptiveColor | Implemented |
| LightDark() closure pattern | Implemented |
| Complete()/CompleteFunc | Implemented |
| Color downsampling (RGB→256→16) | Implemented |

## Rendering

| Feature | Status |
|---------|--------|
| Border gradient blending (blend1D perimeter) | Implemented |
| Border gradient offset rotation | Implemented |
| Reversed bottom/left gradient segments | Implemented |
| ANSI-preserving word wrap (SGR + hyperlink state) | Implemented |
| Display-width-aware renderHorizontalEdge | Implemented |
| ANSI-aware truncate (right) | Implemented |
| ANSI-aware truncateLeft | Implemented |
| ANSI-aware styleRanges (using cut) | Implemented |
| Grouped consecutive rune styling | Implemented |

## Blending

| Feature | Status |
|---------|--------|
| blend1D (CIELAB) | Implemented |
| blend2D (true-center rotation) | Implemented |

## Alignment & Positioning

| Feature | Status |
|---------|--------|
| alignTextHorizontal/Vertical | Implemented |
| Center alignment uses truncation (Go parity) | Implemented |
| place/placeHorizontal/placeVertical | Implemented |
| WhitespaceOption (style + chars) | Implemented |
| joinHorizontal/joinVertical | Implemented |

## Writer / Print Functions

| Feature | Status |
|---------|--------|
| ColorProfile detection | Implemented |
| Downsample (color→profile) | Implemented |
| lipPrint/lipPrintln (auto-downsampling) | Implemented |
| lipSprint/lipSprintln | Implemented |
| lipSprintf | Implemented |
| lipFprint/lipFprintln/lipFprintf | Implemented |
| _downsampleString (parse+rewrite SGR) | Implemented |

## Canvas / Compositor

| Feature | Status |
|---------|--------|
| Canvas (cell-based 2D buffer) | Implemented |
| Canvas compose (ANSI-aware) | Implemented |
| Compositor (z-order layer stack) | Implemented |
| Compositor preserves ANSI (no stripAnsi) | Implemented |
| Layer width/height getters | Implemented |
| Hit testing | Implemented |
| Full cell-based styled compositor (ultraviolet) | Intentionally Omitted (large scope; current ANSI-preserving approach works) |

## Tree Widget

| Feature | Status |
|---------|--------|
| Tree.root / child / children | Implemented |
| TreeLeaf | Implemented |
| Enumerator/Indenter functions | Implemented |
| Root/Item/Enumerator/Indenter styles | Implemented |
| ItemStyleFunc/EnumeratorStyleFunc | Implemented |
| IndenterStyleFunc | Implemented |
| Hide/Hidden (Tree + TreeLeaf) | Implemented |
| Offset(start, end) | Implemented |
| Width (padding) | Implemented |
| Root mutation | Implemented |
| Auto-nesting (ensureParent) | Implemented |
| Leaf-to-subtree promotion | Implemented |
| Per-subtree custom renderer | Implemented |
| Enumerator right-alignment | Implemented |
| Children interface | Implemented (defined; tree uses List internally) |

## List Widget

| Feature | Status |
|---------|--------|
| LipglossList with enumerators | Implemented |
| item()/items() builders | Implemented |
| Hide/Hidden | Implemented |
| Offset(start, end) | Implemented |
| Enumerator right-alignment | Implemented |
| IndenterStyle/IndenterStyleFunc | Implemented |
| Nested list indentation | Implemented |
| List wraps Tree internally | Intentionally Omitted (separate impl with equivalent features) |

## Table Widget

| Feature | Status |
|---------|--------|
| Data interface (StringData, Filter) | Implemented |
| headers/row/rows/data/clearRows | Implemented |
| BaseStyle | Implemented |
| Border configuration | Implemented |
| StyleFunc (per-cell styling) | Implemented |
| Column separator rendering | Implemented |
| Multi-line cell rendering | Implemented |
| Cell wrapping (default on) | Implemented |
| Cell truncation with ellipsis | Implemented |
| TableWidth/TableHeight/YOffset | Implemented |
| Smart resizing (three-phase shrink) | Implemented |
| Row-aware height/overflow with "…" | Implemented |
| Visibility getters (firstVisible/lastVisible/visibleRows) | Implemented |

## Border Definitions

| Feature | Status |
|---------|--------|
| noBorder | Implemented |
| normalBorder | Implemented |
| roundedBorder | Implemented |
| thickBorder | Implemented |
| doubleBorder | Implemented |
| blockBorder | Implemented |
| outerHalfBlockBorder | Implemented |
| innerHalfBlockBorder | Implemented |
| hiddenBorder | Implemented |
| markdownBorder (complete) | Implemented |
| asciiBorder | Implemented |

## API Surface

| Feature | Status |
|---------|--------|
| All per-property getters | Implemented |
| Aggregate getters (padding/margin/border tuples) | Implemented |
| All per-property unsetters | Implemented |
| Bulk unsetters (unsetAlign/Padding/Margins/etc) | Implemented |
| Per-side border color unsetters (8 methods) | Implemented |

## Platform Safety

| Feature | Status |
|---------|--------|
| Props JS/web-safe (two-integer, sequential keys) | Implemented |

## Testing / Process

| Feature | Status |
|---------|--------|
| Golden tests: basic style rendering | Implemented (inline, tabWidth, height, maxHeight, border, setString, alignment) |
| Golden tests: Style.Inherit behavior | Implemented (formatting inherit, no padding inherit, bg→marginBg) |
| Golden tests: inline skips layout | Implemented |
| Golden tests: border shorthand/defaults | Implemented (auto-sides, 1-arg, 2-arg) |
| Golden tests: width + alignment variants | Implemented (default/center/right) |
| Golden tests: table (basic/rounded/columns/no_border) | Implemented |
| Golden tests: table width-constrained wrapping | Implemented |
| Golden tests: table height/yOffset/overflow | Implemented |
| Golden tests: table wrap-off with ellipsis | Implemented |
| Golden tests: table styleFunc | Implemented |
| Golden tests: tree (basic/rounded/nested) | Implemented |
| Golden tests: tree hidden/offset/width/multiline | Implemented |
| Golden tests: list (bullet/arabic/roman) | Implemented |
| Golden tests: list roman alignment (14 items) | Implemented |
| Golden tests: list hidden/offset/nested | Implemented |
| Golden tests: compositor (basic/overlap) | Implemented |
| Golden comparison tool (compare_goldens.dart) | Implemented |
| Parity manifest (no silent omissions) | Implemented (this file) |
| Upstream-vendored goldens | TODO (vendor from pinned Go lipgloss commit when Go toolchain available) |

## Intentional Divergences

| Divergence | Reason |
|------------|--------|
| `LipglossList` class name (not `List`) | Avoids collision with Dart core `List<T>` type |
| `lipColor()` factory (not `Color()`) | Avoids collision with dart:ui `Color` |
| `lipPrint()`/`lipPrintln()` (not `Print()`) | Avoids collision with Dart built-in `print()` |
| Named parameters for functional options | Idiomatic Dart (Go uses variadic functional options) |
| Immutable class + `_copyWith` | Dart equivalent of Go's value semantics |
| `LipglossList` separate from Tree | Equivalent features implemented directly; Go uses `List struct { tree *Tree }` |
| `Canvas` ANSI-preserving (not ultraviolet cells) | ANSI sequences preserved in cells; full styled-cell compositor deferred |
