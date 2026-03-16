import 'dart:io';

import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  Directory('test/testdata/style').createSync(recursive: true);

  File('test/testdata/style/inline.golden')
      .writeAsStringSync(const Style().inline().render('hello\nworld'));
  print('  wrote style/inline.golden');

  File('test/testdata/style/tabwidth_zero.golden')
      .writeAsStringSync(const Style().tabWidth(0).render('hello\tworld'));
  print('  wrote style/tabwidth_zero.golden');

  File('test/testdata/style/height_minimum.golden')
      .writeAsStringSync(const Style().height(5).render('line1\nline2'));
  print('  wrote style/height_minimum.golden');

  File('test/testdata/style/border_auto_sides.golden').writeAsStringSync(
      const Style().borderStyle(roundedBorder).render('hello'));
  print('  wrote style/border_auto_sides.golden');

  File('test/testdata/style/setstring_render.golden')
      .writeAsStringSync(const Style().setString('hello').render('world'));
  print('  wrote style/setstring_render.golden');

  print('All style goldens generated.');
}
