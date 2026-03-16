// Port of lipgloss/examples/canvas/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  // Create layers
  final bg = Layer(
    id: 'background',
    x: 0,
    y: 0,
    z: 0,
    content:
        Style().width(40).height(10).background(lipColor('#2C3E50')).render(''),
  );

  final card1 = Layer(
    id: 'card1',
    x: 2,
    y: 1,
    z: 1,
    content: Style()
        .border(roundedBorder)
        .borderForeground(lipColor('#FF6B6B'))
        .padding(0, 1)
        .render('Card 1'),
  );

  final card2 = Layer(
    id: 'card2',
    x: 15,
    y: 3,
    z: 2,
    content: Style()
        .border(roundedBorder)
        .borderForeground(lipColor('#4ECDC4'))
        .padding(0, 1)
        .render('Card 2'),
  );

  // Compose and render
  final compositor = Compositor()..addLayers([bg, card1, card2]);

  print(compositor.render());
}
