import 'dart:io';
import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/table.dart';
import 'package:dart_lipgloss/tree.dart';
import 'package:dart_lipgloss/list.dart';

void main() {
  // ─── Style goldens ───

  _writeStyle('inline.golden',
      const Style().inline().render('hello\nworld'));

  _writeStyle('tabwidth_zero.golden',
      const Style().tabWidth(0).render('hello\tworld'));

  _writeStyle('height_minimum.golden',
      const Style().height(5).render('line1\nline2'));

  _writeStyle('height_no_crop.golden',
      const Style().height(2).render('line1\nline2\nline3\nline4'));

  _writeStyle('maxheight_crop.golden',
      const Style().maxHeight(2).render('line1\nline2\nline3\nline4'));

  _writeStyle('border_auto_sides.golden',
      const Style().borderStyle(roundedBorder).render('hello'));

  _writeStyle('setstring_render.golden',
      const Style().setString('hello').render('world'));

  _writeStyle('setstring_variadic.golden',
      const Style().setString('hello', ['beautiful', 'world']).render());

  _writeStyle('inherit_formatting.golden', () {
    final parent = Style().bold().italic().foreground(lipColor('#FF0000'));
    final child = Style().underlineBool(true).inherit(parent);
    return child.render('styled');
  }());

  _writeStyle('inherit_no_padding.golden', () {
    final parent = Style().padding(2);
    final child = Style().inherit(parent);
    // Child should NOT have inherited padding
    return '${child.getPaddingTop}:${child.getPaddingRight}:'
        '${child.getPaddingBottom}:${child.getPaddingLeft}';
  }());

  _writeStyle('inline_skips_layout.golden', () {
    final s = Style()
        .inline()
        .padding(1)
        .border(normalBorder)
        .marginLeft(2);
    return s.render('hello\nworld');
  }());

  _writeStyle('border_shorthand_1arg.golden', () {
    final s = Style().border(normalBorder, true);
    return s.render('hi');
  }());

  _writeStyle('border_shorthand_2arg.golden', () {
    final s = Style().border(normalBorder, true, false);
    return s.render('hi');
  }());

  _writeStyle('width_alignment_default.golden',
      Style().width(20).render('short'));

  _writeStyle('width_alignment_center.golden',
      Style().width(20).align(posCenter).render('short'));

  _writeStyle('width_alignment_right.golden',
      Style().width(20).align(posRight).render('short'));

  // ─── Table goldens ───

  _writeTable('basic.golden', () {
    return (Table()
          ..headers(['NAME', 'VALUE'])
          ..rows([
            ['Alpha', '1'],
            ['Beta', '2'],
            ['Gamma', '3']
          ])
          ..borderDef(normalBorder)
          ..borderColumn(true))
        .render();
  });

  _writeTable('rounded.golden', () {
    return (Table()
          ..headers(['NAME', 'VALUE'])
          ..rows([
            ['Alpha', '1'],
            ['Beta', '2'],
            ['Gamma', '3']
          ])
          ..borderDef(roundedBorder)
          ..borderColumn(true))
        .render();
  });

  _writeTable('no_border.golden', () {
    return (Table()
          ..headers(['NAME', 'VALUE'])
          ..rows([
            ['Alpha', '1'],
            ['Beta', '2']
          ])
          ..borderDef(noBorder)
          ..borderEdges(top: false, bottom: false, left: false, right: false)
          ..borderHeader(false))
        .render();
  });

  _writeTable('columns.golden', () {
    return (Table()
          ..headers(['A', 'B', 'C'])
          ..rows([
            ['1', '2', '3'],
            ['4', '5', '6']
          ])
          ..borderDef(normalBorder)
          ..borderColumn(true))
        .render();
  });

  _writeTable('width_constrained.golden', () {
    return (Table()
          ..headers(['NAME', 'DESCRIPTION'])
          ..rows([
            ['Alpha', 'A long description that should be wrapped'],
            ['Beta', 'Short'],
          ])
          ..borderDef(normalBorder)
          ..borderColumn(true)
          ..tableWidth(40))
        .render();
  });

  _writeTable('height_offset.golden', () {
    return (Table()
          ..headers(['ID', 'VAL'])
          ..rows([
            ['1', 'A'],
            ['2', 'B'],
            ['3', 'C'],
            ['4', 'D'],
            ['5', 'E'],
          ])
          ..borderDef(normalBorder)
          ..borderColumn(true)
          ..tableHeight(8)
          ..yOffset(1))
        .render();
  });

  _writeTable('wrap_off.golden', () {
    return (Table()
          ..headers(['NAME', 'DESC'])
          ..rows([
            ['Alpha', 'A very long description exceeding column width'],
          ])
          ..borderDef(normalBorder)
          ..borderColumn(true)
          ..tableWidth(30)
          ..wrapContent(false))
        .render();
  });

  _writeTable('style_func.golden', () {
    return (Table()
          ..headers(['NAME', 'VALUE'])
          ..rows([
            ['Alpha', '1'],
            ['Beta', '2'],
          ])
          ..borderDef(normalBorder)
          ..borderColumn(true)
          ..styleFunc((row, col) {
            if (row == headerRow) return Style().bold();
            return const Style();
          }))
        .render();
  });

  // ─── Tree goldens ───

  _writeTree('basic.golden', () {
    return (Tree.root('Root')
          ..child('Alpha')
          ..child('Beta')
          ..child('Gamma'))
        .render();
  });

  _writeTree('rounded.golden', () {
    final t = Tree.root('Root')
      ..child('Alpha')
      ..child('Beta')
      ..child('Gamma');
    t.enumerator(roundedEnumerator);
    t.indenter(roundedIndenter);
    return t.render();
  });

  _writeTree('nested.golden', () {
    return (Tree.root('Root')
          ..child(Tree.root('Branch A')
            ..child('Leaf 1')
            ..child('Leaf 2'))
          ..child(Tree.root('Branch B')..child('Leaf 3'))
          ..child('Leaf C'))
        .render();
  });

  _writeTree('hidden.golden', () {
    final t = Tree.root('Root')
      ..child('Visible')
      ..child(TreeLeaf('Hidden')..hide())
      ..child('Also Visible');
    return t.render();
  });

  _writeTree('offset.golden', () {
    final t = Tree.root('Root')
      ..child('A')
      ..child('B')
      ..child('C')
      ..child('D')
      ..child('E');
    t.offset(1, 1); // skip first and last
    return t.render();
  });

  _writeTree('width_padding.golden', () {
    final t = Tree.root('Root')
      ..child('Short')
      ..child('X');
    t.width(30);
    return t.render();
  });

  _writeTree('multiline.golden', () {
    return (Tree.root('Root')
          ..child('Line1\nLine2\nLine3')
          ..child('After'))
        .render();
  });

  // ─── List goldens ───

  _writeList('bullet.golden', () {
    return (LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(bullet))
        .render();
  });

  _writeList('arabic.golden', () {
    return (LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(arabic))
        .render();
  });

  _writeList('roman.golden', () {
    return (LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(roman))
        .render();
  });

  _writeList('roman_alignment.golden', () {
    // Test right-alignment of Roman numerals with varying widths
    final items = List.generate(14, (i) => 'Item ${i + 1}');
    return (LipglossList(items)..enumerator(roman)).render();
  });

  _writeList('hidden.golden', () {
    final l = LipglossList(['A', 'B', 'C'])..hide();
    return l.render();
  });

  _writeList('offset.golden', () {
    final l = LipglossList(['A', 'B', 'C', 'D', 'E'])..offset(1, 1);
    return l.render();
  });

  _writeList('nested.golden', () {
    final inner = LipglossList(['Sub A', 'Sub B'])..enumerator(dash);
    final outer = LipglossList(['Top 1', inner, 'Top 2'])..enumerator(bullet);
    return outer.render();
  });

  // ─── Canvas/Compositor goldens ───

  Directory('test/testdata/canvas').createSync(recursive: true);
  _write('test/testdata/canvas/basic_compositor.golden', () {
    final c = Compositor();
    c.addLayer(Layer(content: 'Hello', x: 0, y: 0, z: 0));
    c.addLayer(Layer(content: 'World', x: 6, y: 0, z: 1));
    return c.render();
  });

  _write('test/testdata/canvas/overlap.golden', () {
    final c = Compositor();
    c.addLayer(Layer(content: 'AAAA\nAAAA', x: 0, y: 0, z: 0));
    c.addLayer(Layer(content: 'BB', x: 1, y: 0, z: 1));
    return c.render();
  });

  print('All golden files generated.');
}

void _write(String path, String Function() renderer) {
  final content = renderer();
  File(path).writeAsStringSync(content);
  print('  wrote $path (${content.length} bytes)');
}

void _writeStyle(String name, String content) {
  Directory('test/testdata/style').createSync(recursive: true);
  _write('test/testdata/style/$name', () => content);
}

void _writeTable(String name, String Function() renderer) {
  Directory('test/testdata/table').createSync(recursive: true);
  _write('test/testdata/table/$name', renderer);
}

void _writeTree(String name, String Function() renderer) {
  Directory('test/testdata/tree').createSync(recursive: true);
  _write('test/testdata/tree/$name', renderer);
}

void _writeList(String name, String Function() renderer) {
  Directory('test/testdata/list').createSync(recursive: true);
  _write('test/testdata/list/$name', renderer);
}
