// Simple styling example for dart_lipgloss.
import 'package:dart_lipgloss/dart_lipgloss.dart';

void main() {
  // Basic text styling
  print(Style().bold().render('Bold text'));
  print(Style().italic().render('Italic text'));
  print(Style().faint().render('Faint text'));
  print(Style().underline(UnderlineStyle.single).render('Underlined'));
  print(Style().strikethrough().render('Strikethrough'));

  // Combining styles
  final fancy = Style()
      .bold()
      .italic()
      .foreground(lipColor('#FF6B6B'))
      .background(lipColor('#2C3E50'))
      .padding(0, 1);

  print(fancy.render('Fancy styled text'));

  // Width and alignment
  const w = 30;
  print(Style().width(w).align(posLeft).render('Left'));
  print(Style().width(w).align(posCenter).render('Center'));
  print(Style().width(w).align(posRight).render('Right'));
}
