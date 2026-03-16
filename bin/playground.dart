// Dart Lip Gloss Interactive Playground
// Run: dart run bin/playground.dart
// Navigate with arrow keys, press 'q' to quit.

import 'dart:io';
import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/table.dart';
import 'package:dart_lipgloss/list.dart';
import 'package:dart_lipgloss/tree.dart';

void main() {
  if (!stdout.hasTerminal) {
    print('This playground requires an interactive terminal.');
    print('Run: dart run bin/playground.dart');
    return;
  }

  stdin.echoMode = false;
  stdin.lineMode = false;

  var currentSection = 0;
  final sections = ['Styles', 'Borders', 'Colors', 'Table', 'List', 'Tree'];

  void render() {
    // Clear screen
    stdout.write('\x1b[2J\x1b[H');

    // Header with section tabs
    final tabs = <String>[];
    for (var i = 0; i < sections.length; i++) {
      final style = i == currentSection
          ? Style()
              .bold()
              .foreground(lipColor('#FAFAFA'))
              .background(lipColor('#7D56F4'))
              .padding(0, 1)
          : Style().faint().padding(0, 1);
      tabs.add(style.render(sections[i]));
    }
    print(joinHorizontal(posCenter, tabs));
    print('');

    // Render current section
    switch (currentSection) {
      case 0:
        _renderStyles();
      case 1:
        _renderBorders();
      case 2:
        _renderColors();
      case 3:
        _renderTable();
      case 4:
        _renderList();
      case 5:
        _renderTree();
    }

    print('');
    print(Style().faint().render('  ← → to navigate  •  q to quit'));
  }

  render();

  stdin.listen((data) {
    if (data.isNotEmpty && data[0] == 113) {
      // 'q'
      stdout.write('\x1b[2J\x1b[H');
      stdin.echoMode = true;
      stdin.lineMode = true;
      exit(0);
    }
    if (data.length >= 3 && data[0] == 27 && data[1] == 91) {
      if (data[2] == 67) {
        currentSection = (currentSection + 1) % sections.length;
      }
      if (data[2] == 68) {
        currentSection =
            (currentSection - 1 + sections.length) % sections.length;
      }
    }
    render();
  });
}

void _renderStyles() {
  print(Style().bold().render('Bold'));
  print(Style().italic().render('Italic'));
  print(Style().faint().render('Faint'));
  print(Style().underline(UnderlineStyle.single).render('Underline'));
  print(Style().strikethrough().render('Strikethrough'));
  print(Style().reverse().render('Reverse'));
  print('');
  print(Style()
      .bold()
      .foreground(lipColor('#FF6B6B'))
      .background(lipColor('#2C3E50'))
      .padding(0, 1)
      .render('Styled with colors'));
}

void _renderBorders() {
  final borders = {
    'Normal': normalBorder,
    'Rounded': roundedBorder,
    'Thick': thickBorder,
    'Double': doubleBorder,
  };

  final cards = <String>[];
  for (final entry in borders.entries) {
    cards.add(Style()
        .border(entry.value)
        .borderForeground(lipColor('#7D56F4'))
        .padding(0, 1)
        .width(14)
        .render(entry.key));
  }
  print(joinHorizontal(posTop, cards));
}

void _renderColors() {
  for (var i = 0; i < 16; i++) {
    stdout.write(Style().background(ANSIColor(i)).render('  '));
  }
  print('  ANSI 16');
  print('');
  for (var i = 0; i < 60; i++) {
    final c = RGBColor(
      (i / 60 * 255).round(),
      ((60 - i) / 60 * 255).round(),
      128,
    );
    stdout.write(Style().background(c).render(' '));
  }
  print('  TrueColor');
}

void _renderTable() {
  final t = Table()
    ..headers(['Name', 'Value'])
    ..rows([
      ['Bold', 'true'],
      ['Color', '#7D56F4'],
      ['Border', 'rounded'],
    ])
    ..borderDef(roundedBorder)
    ..borderColumn(true)
    ..borderStyleDef(Style().foreground(lipColor('#4ECDC4')));
  print(t.render());
}

void _renderList() {
  final l = LipglossList(['First item', 'Second item', 'Third item'])
    ..enumerator(bullet)
    ..enumeratorStyle(Style().foreground(lipColor('#FF6B6B')));
  print(l.render());
}

void _renderTree() {
  final t = Tree.root('root')
    ..child(Tree.root('src')
      ..child('main.dart')
      ..child('util.dart'))
    ..child(Tree.root('test')..child('main_test.dart'))
    ..child('pubspec.yaml');
  t.enumerator(roundedEnumerator);
  t.indenter(roundedIndenter);
  print(t.render());
}
