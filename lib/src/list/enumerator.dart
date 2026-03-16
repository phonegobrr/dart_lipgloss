// Ported from charmbracelet/lipgloss/list
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

/// Function that generates the enumerator prefix for a list item.
typedef ListEnumeratorFunc = String Function(List<Object> items, int i);

/// Bullet enumerator: •
String bullet(List<Object> items, int i) => '• ';

/// Dash enumerator: -
String dash(List<Object> items, int i) => '- ';

/// Asterisk enumerator: *
String asterisk(List<Object> items, int i) => '* ';

/// Arabic numeral enumerator: 1. 2. 3.
String arabic(List<Object> items, int i) => '${i + 1}. ';

/// Roman numeral enumerator: I. II. III.
String roman(List<Object> items, int i) => '${_toRoman(i + 1)}. ';

/// Lowercase alphabet enumerator: a. b. c.
String alphabet(List<Object> items, int i) =>
    '${String.fromCharCode(97 + (i % 26))}. ';

/// Uppercase alphabet enumerator: A. B. C.
String alphabetUpper(List<Object> items, int i) =>
    '${String.fromCharCode(65 + (i % 26))}. ';

/// Convert an integer to a Roman numeral string.
String _toRoman(int num) {
  if (num <= 0 || num > 3999) return num.toString();

  const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const symbols = [
    'M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I',
  ];

  final buf = StringBuffer();
  var remaining = num;

  for (var i = 0; i < values.length; i++) {
    while (remaining >= values[i]) {
      buf.write(symbols[i]);
      remaining -= values[i];
    }
  }

  return buf.toString();
}
