// Port of lipgloss/examples/layout/main.go
// Original: https://github.com/charmbracelet/lipgloss
// MIT Licensed by Charmbracelet, Inc.

import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  final statusStyle = Style()
      .foreground(lipColor('#FFFDF5'))
      .background(lipColor('#FF5F87'))
      .padding(0, 1)
      .marginRight(1);

  final encodingStyle = Style()
      .foreground(lipColor('#FFFDF5'))
      .background(lipColor('#A550DF'))
      .padding(0, 1);

  final fishCakeStyle = Style()
      .foreground(lipColor('#FFFDF5'))
      .background(lipColor('#6124DF'))
      .padding(0, 1);

  // Build status bar
  final statusKey = statusStyle.render('STATUS');
  final encoding = encodingStyle.render('UTF-8');
  final fishCake = fishCakeStyle.render('Fish Cake');
  final statusBar = joinHorizontal(posCenter, [statusKey, encoding, fishCake]);

  // Dialog box
  final dialogStyle = Style()
      .border(roundedBorder)
      .borderForeground(lipColor('#874BFD'))
      .padding(1, 2)
      .width(50);

  final buttonStyle = Style()
      .foreground(lipColor('#FFF7DB'))
      .background(lipColor('#888B7E'))
      .padding(0, 3)
      .marginTop(1);

  final activeButtonStyle = Style()
      .foreground(lipColor('#FFF7DB'))
      .background(lipColor('#F25D94'))
      .padding(0, 3)
      .marginTop(1)
      .marginRight(2);

  final question = Style()
      .width(46)
      .align(posCenter)
      .render('Are you sure you want to eat marmalade?');

  final yesButton = activeButtonStyle.render('Yes');
  final noButton = buttonStyle.render('Maybe');

  final buttons = joinHorizontal(posTop, [yesButton, noButton]);
  final dialog = joinVertical(posCenter, [question, buttons]);

  print(dialogStyle.render(dialog));
  print('');
  print(statusBar);
}
