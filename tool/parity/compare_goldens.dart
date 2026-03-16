// Compares Dart-rendered output against vendored upstream Go lipgloss golden files.
//
// Usage: dart run tool/parity/compare_goldens.dart
//
// This tool renders the same fixtures as Go lipgloss test suites and compares
// the output against vendored golden files in test/testdata/upstream/.
//
// To update vendored goldens, run the Go test suite from a pinned lipgloss commit
// and copy the testdata output files into test/testdata/upstream/.
//
// If no upstream goldens are found, falls back to comparing against
// self-generated goldens (the existing test/testdata/ files).
import 'dart:io';

import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/list.dart';
import 'package:dart_lipgloss/table.dart';
import 'package:dart_lipgloss/tree.dart';

void main() {
  final upstreamDir = Directory('test/testdata/upstream');
  final hasUpstream = upstreamDir.existsSync();

  if (hasUpstream) {
    print('Comparing against upstream vendored goldens...');
  } else {
    print('No upstream goldens found at test/testdata/upstream/');
    print('Comparing against self-generated goldens...');
    print(
        'To vendor upstream goldens, copy Go lipgloss testdata to test/testdata/upstream/');
  }

  var passed = 0;
  var failed = 0;
  var skipped = 0;

  // ─── Style fixtures ───

  void check(String name, String actual, String goldenPath) {
    final file = File(goldenPath);
    if (!file.existsSync()) {
      print('  SKIP $name (golden not found: $goldenPath)');
      skipped++;
      return;
    }
    final expected = file.readAsStringSync();
    if (actual == expected) {
      print('  PASS $name');
      passed++;
    } else {
      print('  FAIL $name');
      print(
          '    Expected ${expected.length} chars, got ${actual.length} chars');
      // Show first difference
      final minLen =
          actual.length < expected.length ? actual.length : expected.length;
      for (var i = 0; i < minLen; i++) {
        if (actual.codeUnitAt(i) != expected.codeUnitAt(i)) {
          print(
              '    First diff at offset $i: got ${actual.codeUnitAt(i)}, expected ${expected.codeUnitAt(i)}');
          break;
        }
      }
      if (actual.length != expected.length) {
        print(
            '    Length mismatch: got ${actual.length}, expected ${expected.length}');
      }
      failed++;
    }
  }

  String basePath(String name) {
    if (hasUpstream) return 'test/testdata/upstream/$name';
    return 'test/testdata/$name';
  }

  // ─── Table fixtures ───

  check('table/basic', () {
    final t = Table()
      ..headers(['NAME', 'VALUE'])
      ..rows([
        ['Alpha', '1'],
        ['Beta', '2'],
        ['Gamma', '3']
      ])
      ..borderDef(normalBorder)
      ..borderColumn(true);
    return t.render();
  }(), basePath('table/basic.golden'));

  check('table/rounded', () {
    final t = Table()
      ..headers(['NAME', 'VALUE'])
      ..rows([
        ['Alpha', '1'],
        ['Beta', '2'],
        ['Gamma', '3']
      ])
      ..borderDef(roundedBorder)
      ..borderColumn(true);
    return t.render();
  }(), basePath('table/rounded.golden'));

  check('table/no_border', () {
    final t = Table()
      ..headers(['NAME', 'VALUE'])
      ..rows([
        ['Alpha', '1'],
        ['Beta', '2']
      ])
      ..borderDef(noBorder)
      ..borderEdges(top: false, bottom: false, left: false, right: false)
      ..borderHeader(false);
    return t.render();
  }(), basePath('table/no_border.golden'));

  check('table/columns', () {
    final t = Table()
      ..headers(['A', 'B', 'C'])
      ..rows([
        ['1', '2', '3'],
        ['4', '5', '6']
      ])
      ..borderDef(normalBorder)
      ..borderColumn(true);
    return t.render();
  }(), basePath('table/columns.golden'));

  // ─── Tree fixtures ───

  check('tree/basic', () {
    final t = Tree.root('Root')
      ..child('Alpha')
      ..child('Beta')
      ..child('Gamma');
    return t.render();
  }(), basePath('tree/basic.golden'));

  check('tree/rounded', () {
    final t = Tree.root('Root')
      ..child('Alpha')
      ..child('Beta')
      ..child('Gamma');
    t.enumerator(roundedEnumerator);
    t.indenter(roundedIndenter);
    return t.render();
  }(), basePath('tree/rounded.golden'));

  check('tree/nested', () {
    final t = Tree.root('Root')
      ..child(Tree.root('Branch A')
        ..child('Leaf 1')
        ..child('Leaf 2'))
      ..child(Tree.root('Branch B')..child('Leaf 3'))
      ..child('Leaf C');
    return t.render();
  }(), basePath('tree/nested.golden'));

  // ─── List fixtures ───

  check('list/bullet', () {
    final l = LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(bullet);
    return l.render();
  }(), basePath('list/bullet.golden'));

  check('list/arabic', () {
    final l = LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(arabic);
    return l.render();
  }(), basePath('list/arabic.golden'));

  check('list/roman', () {
    final l = LipglossList(['Apple', 'Banana', 'Cherry'])..enumerator(roman);
    return l.render();
  }(), basePath('list/roman.golden'));

  // ─── Style-specific fixtures ───

  check('style/inline', () {
    return const Style().inline().render('hello\nworld');
  }(), basePath('style/inline.golden'));

  check('style/tabwidth_zero', () {
    return const Style().tabWidth(0).render('hello\tworld');
  }(), basePath('style/tabwidth_zero.golden'));

  check('style/height_minimum', () {
    return const Style().height(5).render('line1\nline2');
  }(), basePath('style/height_minimum.golden'));

  check('style/border_auto_sides', () {
    return const Style().borderStyle(roundedBorder).render('hello');
  }(), basePath('style/border_auto_sides.golden'));

  check('style/setstring_render', () {
    return const Style().setString('hello').render('world');
  }(), basePath('style/setstring_render.golden'));

  // ─── Summary ───

  print('');
  print('Results: $passed passed, $failed failed, $skipped skipped');
  if (failed > 0) {
    exit(1);
  }
}
