// Dart Lip Gloss Demo — comprehensive feature showcase.
// Compile: dart compile exe bin/demo.dart -o build/dart_lipgloss_demo

import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/table.dart';
import 'package:dart_lipgloss/list.dart';
import 'package:dart_lipgloss/tree.dart';

void main(List<String> args) {
  if (args.contains('--about')) {
    print('Dart Lip Gloss Demo');
    print('A native Dart port of Lip Gloss by Charmbracelet.');
    print('https://github.com/charmbracelet/lipgloss');
    return;
  }

  if (args.contains('--smoke-test')) {
    print(Style().bold().render('Smoke test passed'));
    return;
  }

  // Section 1: Colors
  _printSection('Colors');
  _demoColors();

  // Section 2: Text Formatting
  _printSection('Text Formatting');
  _demoFormatting();

  // Section 3: Borders
  _printSection('Borders');
  _demoBorders();

  // Section 4: Layout
  _printSection('Layout');
  _demoLayout();

  // Section 5: Compositing
  _printSection('Compositing');
  _demoCompositing();

  // Section 6: Table
  _printSection('Table');
  _demoTable();

  // Section 7: List
  _printSection('List');
  _demoList();

  // Section 8: Tree
  _printSection('Tree');
  _demoTree();

  // Section 9: Gradients
  _printSection('Gradients');
  _demoGradients();
}

void _printSection(String title) {
  print('');
  print(Style()
      .bold()
      .foreground(lipColor('#FAFAFA'))
      .background(lipColor('#7D56F4'))
      .padding(0, 1)
      .render(' $title '));
  print('');
}

void _demoColors() {
  // ANSI 16 colors
  final buf = StringBuffer();
  for (var i = 0; i < 16; i++) {
    buf.write(Style().background(ANSIColor(i)).render('  '));
  }
  print('ANSI 16:  $buf');

  // 256 color gradient sample
  final buf256 = StringBuffer();
  for (var i = 16; i < 232; i++) {
    buf256.write(Style().background(ANSI256Color(i)).render(' '));
  }
  print('ANSI 256: $buf256');

  // TrueColor gradient
  final trueColorBuf = StringBuffer();
  for (var i = 0; i < 60; i++) {
    final hue = (i / 60 * 360).round();
    final color = _hslToRgb(hue, 0.8, 0.5);
    trueColorBuf.write(Style().background(color).render(' '));
  }
  print('TrueColor: $trueColorBuf');
}

void _demoFormatting() {
  print(Style().bold().render('Bold text'));
  print(Style().italic().render('Italic text'));
  print(Style().faint().render('Faint text'));
  print(Style().underline(UnderlineStyle.single).render('Underlined text'));
  print(Style().strikethrough().render('Strikethrough text'));
  print(Style().reverse().render('Reversed text'));
  print(Style()
      .bold()
      .foreground(lipColor('#FF6B6B'))
      .render('Colored bold text'));
  print(Style()
      .italic()
      .foreground(lipColor('#4ECDC4'))
      .background(lipColor('#2C3E50'))
      .render('Styled text with background'));
}

void _demoBorders() {
  final label = Style().bold().foreground(lipColor('#FAFAFA'));
  final borders = {
    'Normal': normalBorder,
    'Rounded': roundedBorder,
    'Thick': thickBorder,
    'Double': doubleBorder,
    'Block': blockBorder,
    'Hidden': hiddenBorder,
    'ASCII': asciiBorder,
  };

  final cards = <String>[];
  for (final entry in borders.entries) {
    final card = Style()
        .border(entry.value)
        .borderForeground(lipColor('#7D56F4'))
        .padding(0, 1)
        .width(14)
        .render(label.render(entry.key));
    cards.add(card);
  }

  // Print 4 per row
  for (var i = 0; i < cards.length; i += 4) {
    final row = cards.sublist(i, (i + 4).clamp(0, cards.length));
    print(joinHorizontal(posTop, row));
  }
}

void _demoLayout() {
  // Padding
  print(Style()
      .padding(1, 2)
      .background(lipColor('#3C3836'))
      .foreground(lipColor('#EBDBB2'))
      .render('Padded content'));
  print('');

  // Alignment
  const w = 40;
  print(Style().width(w).align(posLeft).render('Left aligned'));
  print(Style().width(w).align(posCenter).render('Center aligned'));
  print(Style().width(w).align(posRight).render('Right aligned'));
}

void _demoCompositing() {
  final box1 = Style()
      .border(roundedBorder)
      .borderForeground(lipColor('#FF6B6B'))
      .padding(0, 1)
      .render('Box 1');

  final box2 = Style()
      .border(roundedBorder)
      .borderForeground(lipColor('#4ECDC4'))
      .padding(0, 1)
      .render('Box 2');

  final box3 = Style()
      .border(roundedBorder)
      .borderForeground(lipColor('#FFE66D'))
      .padding(0, 1)
      .render('Box 3');

  print('joinHorizontal:');
  print(joinHorizontal(posCenter, [box1, box2, box3]));
  print('');
  print('joinVertical:');
  print(joinVertical(posCenter, [box1, box2, box3]));
}

void _demoTable() {
  final t = Table()
    ..headers(['Language', 'Greeting', 'Formal'])
    ..rows([
      ['English', 'Hello', 'Good day'],
      ['Chinese', 'Nǐ hǎo', 'Nín hǎo'],
      ['Japanese', 'Konnichiwa', 'Gokigen\'yō'],
      ['Arabic', 'Marhaba', 'Ahlan wa sahlan'],
      ['Spanish', 'Hola', 'Buenos días'],
    ])
    ..borderDef(roundedBorder)
    ..borderColumn(true)
    ..borderStyleDef(Style().foreground(lipColor('#7D56F4')));

  print(t.render());
}

void _demoList() {
  final list = LipglossList([
    'Bread',
    'Milk',
    'Eggs',
    'Butter',
    'Cheese',
  ])
    ..enumerator(arabic)
    ..enumeratorStyle(Style().foreground(lipColor('#FF6B6B')));

  print(list.render());
}

void _demoTree() {
  final tree = Tree.root('Operating Systems')
    ..child(Tree.root('Linux')
      ..child('Ubuntu')
      ..child('Arch')
      ..child('Fedora'))
    ..child(Tree.root('macOS')
      ..child('Ventura')
      ..child('Sonoma'))
    ..child(Tree.root('Windows')
      ..child('10')
      ..child('11'));

  tree.enumerator(roundedEnumerator);
  tree.indenter(roundedIndenter);
  tree.enumeratorStyle(Style().foreground(lipColor('#4ECDC4')));

  print(tree.render());
}

void _demoGradients() {
  // 1D gradient
  final stops = [
    lipColor('#FF6B6B'),
    lipColor('#FFE66D'),
    lipColor('#4ECDC4'),
    lipColor('#7D56F4'),
  ];

  final gradient = blend1D(60, stops);
  final buf = StringBuffer();
  for (final c in gradient) {
    buf.write(Style().background(c).render(' '));
  }
  print('1D Gradient:');
  print(buf);
}

/// Convert HSL to RGBColor.
RGBColor _hslToRgb(int h, double s, double l) {
  final hNorm = h / 360.0;
  double hue2rgb(double p, double q, double t) {
    var tt = t;
    if (tt < 0) tt += 1;
    if (tt > 1) tt -= 1;
    if (tt < 1 / 6) return p + (q - p) * 6 * tt;
    if (tt < 1 / 2) return q;
    if (tt < 2 / 3) return p + (q - p) * (2 / 3 - tt) * 6;
    return p;
  }

  final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
  final p = 2 * l - q;
  final r = hue2rgb(p, q, hNorm + 1 / 3);
  final g = hue2rgb(p, q, hNorm);
  final b = hue2rgb(p, q, hNorm - 1 / 3);

  return RGBColor(
    (r * 255).round().clamp(0, 255),
    (g * 255).round().clamp(0, 255),
    (b * 255).round().clamp(0, 255),
  );
}
