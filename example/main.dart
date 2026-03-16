// Minimal pub.dev example for dart_lipgloss.
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  final style = Style()
      .bold()
      .foreground(lipColor('#FAFAFA'))
      .background(lipColor('#7D56F4'))
      .paddingTop(2)
      .paddingLeft(4)
      .width(22);

  print(style.render('Hello, Lip Gloss'));
}
