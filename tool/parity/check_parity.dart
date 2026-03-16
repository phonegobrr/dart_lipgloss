// Cross-language parity checker for dart_lipgloss.
//
// Renders known inputs through the Dart library and compares against
// vendored golden fixture files from the Go upstream test suite.
//
// Usage: dart run tool/parity/check_parity.dart

import 'dart:io';
import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/table.dart';
import 'package:dart_lipgloss/tree.dart';
import 'package:dart_lipgloss/list.dart';

void main() {
  var passed = 0;
  var failed = 0;
  var skipped = 0;

  // Discover golden files
  final testdataDir = Directory('test/testdata');
  if (!testdataDir.existsSync()) {
    print('No test/testdata directory found. Run from project root.');
    exit(1);
  }

  final goldenFiles = testdataDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.golden'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (goldenFiles.isEmpty) {
    print('No .golden files found in test/testdata/');
    exit(0);
  }

  print('Parity check: ${goldenFiles.length} golden fixtures found\n');

  for (final file in goldenFiles) {
    final name = file.path.replaceFirst('test/testdata/', '');
    final expected = _normalizeNewlines(file.readAsStringSync());

    // Match fixture to a render function
    final renderer = _matchRenderer(name);
    if (renderer == null) {
      print('  SKIP  $name (no matching renderer)');
      skipped++;
      continue;
    }

    final actual = _normalizeNewlines(renderer());

    if (actual == expected) {
      print('  PASS  $name');
      passed++;
    } else {
      print('  FAIL  $name');
      _printDiff(expected, actual);
      failed++;
    }
  }

  print('\n${'─' * 50}');
  print('Parity: $passed passed, $failed failed, $skipped skipped');

  if (failed > 0) exit(1);
}

/// Normalize line endings for cross-platform comparison.
String _normalizeNewlines(String s) =>
    s.replaceAll('\r\n', '\n').trimRight();

/// Match a golden filename to a render function.
/// Returns null if no renderer matches.
String Function()? _matchRenderer(String name) {
  // Table fixtures
  if (name == 'table/basic.golden') return _renderTableBasic;
  if (name == 'table/rounded.golden') return _renderTableRounded;
  if (name == 'table/no_border.golden') return _renderTableNoBorder;
  if (name == 'table/columns.golden') return _renderTableColumns;

  // Tree fixtures
  if (name == 'tree/basic.golden') return _renderTreeBasic;
  if (name == 'tree/rounded.golden') return _renderTreeRounded;
  if (name == 'tree/nested.golden') return _renderTreeNested;

  // List fixtures
  if (name == 'list/bullet.golden') return _renderListBullet;
  if (name == 'list/arabic.golden') return _renderListArabic;
  if (name == 'list/roman.golden') return _renderListRoman;

  return null;
}

// ─── Table renderers ───

String _renderTableBasic() {
  final t = Table()
    ..headers(['NAME', 'VALUE'])
    ..rows([
      ['Alpha', '1'],
      ['Beta', '2'],
      ['Gamma', '3'],
    ])
    ..borderDef(normalBorder)
    ..borderColumn(true);
  return t.render();
}

String _renderTableRounded() {
  final t = Table()
    ..headers(['NAME', 'VALUE'])
    ..rows([
      ['Alpha', '1'],
      ['Beta', '2'],
      ['Gamma', '3'],
    ])
    ..borderDef(roundedBorder)
    ..borderColumn(true);
  return t.render();
}

String _renderTableNoBorder() {
  final t = Table()
    ..headers(['NAME', 'VALUE'])
    ..rows([
      ['Alpha', '1'],
      ['Beta', '2'],
    ])
    ..borderDef(noBorder)
    ..borderEdges(top: false, bottom: false, left: false, right: false)
    ..borderHeader(false);
  return t.render();
}

String _renderTableColumns() {
  final t = Table()
    ..headers(['A', 'B', 'C'])
    ..rows([
      ['1', '2', '3'],
      ['4', '5', '6'],
    ])
    ..borderDef(normalBorder)
    ..borderColumn(true);
  return t.render();
}

// ─── Tree renderers ───

String _renderTreeBasic() {
  final t = Tree.root('Root')
    ..child('Alpha')
    ..child('Beta')
    ..child('Gamma');
  return t.render();
}

String _renderTreeRounded() {
  final t = Tree.root('Root')
    ..child('Alpha')
    ..child('Beta')
    ..child('Gamma');
  t.enumerator(roundedEnumerator);
  t.indenter(roundedIndenter);
  return t.render();
}

String _renderTreeNested() {
  final t = Tree.root('Root')
    ..child(
        Tree.root('Branch A')
          ..child('Leaf 1')
          ..child('Leaf 2'))
    ..child(
        Tree.root('Branch B')
          ..child('Leaf 3'))
    ..child('Leaf C');
  return t.render();
}

// ─── List renderers ───

String _renderListBullet() {
  final l = LipglossList(['Apple', 'Banana', 'Cherry'])
    ..enumerator(bullet);
  return l.render();
}

String _renderListArabic() {
  final l = LipglossList(['Apple', 'Banana', 'Cherry'])
    ..enumerator(arabic);
  return l.render();
}

String _renderListRoman() {
  final l = LipglossList(['Apple', 'Banana', 'Cherry'])
    ..enumerator(roman);
  return l.render();
}

// ─── Diff helper ───

void _printDiff(String expected, String actual) {
  final expLines = expected.split('\n');
  final actLines = actual.split('\n');
  final maxLines =
      expLines.length > actLines.length ? expLines.length : actLines.length;

  for (var i = 0; i < maxLines; i++) {
    final exp = i < expLines.length ? expLines[i] : '<missing>';
    final act = i < actLines.length ? actLines[i] : '<missing>';
    if (exp != act) {
      print('    line ${i + 1}:');
      print('      expected: ${_escape(exp)}');
      print('      actual:   ${_escape(act)}');
    }
  }
}

String _escape(String s) =>
    s.replaceAll('\x1b', '\\x1b').replaceAll('\x07', '\\x07');
