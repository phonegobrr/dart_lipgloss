// Port of lipgloss/examples/table/chess/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';
import 'package:dart_lipgloss/table.dart';

void main() {
  // Chess board representation using a table
  final pieces = [
    ['♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜'],
    ['♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟'],
    [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
    [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
    [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
    [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
    ['♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙'],
    ['♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖'],
  ];

  final headers = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

  final lightSquare = Style().background(lipColor('#F0D9B5'));
  final darkSquare = Style().background(lipColor('#B58863'));

  final t = Table()
    ..headers(headers)
    ..rows(pieces)
    ..borderDef(normalBorder)
    ..borderColumn(true)
    ..borderStyleDef(Style().foreground(lipColor('#555555')))
    ..styleFunc((row, col) {
      if (row == headerRow) {
        return Style().bold().foreground(lipColor('#888888'));
      }
      // Checkerboard pattern
      final isLight = (row + col) % 2 == 0;
      return isLight ? lightSquare : darkSquare;
    });

  print(Style().bold().foreground(lipColor('#FAFAFA')).render('Chess Board'));
  print('');
  print(t.render());
}
