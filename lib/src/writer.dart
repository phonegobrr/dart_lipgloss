// Ported from charmbracelet/lipgloss writer.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'dart:io';

import 'ansi/parser.dart';
import 'color.dart';

/// Terminal color profile.
enum ColorProfile {
  /// No color support.
  ascii,

  /// 16 colors (ANSI).
  ansi,

  /// 256 colors.
  ansi256,

  /// 16 million colors (TrueColor).
  trueColor,
}

/// Detect the terminal's color profile.
ColorProfile detectColorProfile([IOSink? output]) {
  // Check NO_COLOR env var → ascii
  if (Platform.environment.containsKey('NO_COLOR')) return ColorProfile.ascii;

  // Check FORCE_COLOR env var → at least ansi
  if (Platform.environment.containsKey('FORCE_COLOR')) {
    final level = Platform.environment['FORCE_COLOR'] ?? '';
    if (level == '3') return ColorProfile.trueColor;
    if (level == '2') return ColorProfile.ansi256;
    return ColorProfile.ansi;
  }

  // Check if stdout supports ANSI escapes
  if (output == null || output == stdout) {
    if (!stdout.supportsAnsiEscapes) return ColorProfile.ascii;
  }

  // Check COLORTERM for truecolor
  final colorterm = (Platform.environment['COLORTERM'] ?? '').toLowerCase();
  if (['truecolor', 'true-color', '24bit'].contains(colorterm)) {
    return ColorProfile.trueColor;
  }

  // Check TERM for 256color
  final term = Platform.environment['TERM'] ?? '';
  if (term.contains('256color')) return ColorProfile.ansi256;

  // Check if terminal is attached
  if (stdout.hasTerminal) return ColorProfile.ansi;

  return ColorProfile.ascii;
}

/// Downsample a LipglossColor to fit within [profile].
LipglossColor downsample(LipglossColor c, ColorProfile profile) {
  switch (c) {
    case NoColor():
      return c;
    case ANSIColor():
      if (profile == ColorProfile.ascii) return const NoColor();
      return c;
    case ANSI256Color():
      if (profile == ColorProfile.ascii) return const NoColor();
      if (profile == ColorProfile.ansi) return rgbToAnsi16(c);
      return c;
    case RGBColor():
      if (profile == ColorProfile.ascii) return const NoColor();
      if (profile == ColorProfile.ansi) return rgbToAnsi16(c);
      if (profile == ColorProfile.ansi256) return rgbToAnsi256(c);
      return c;
  }
}

/// Downsample ANSI color sequences in a string to fit within [profile].
///
/// Parses CSI SGR sequences and downgrades color parameters.
/// Non-color sequences and plain text pass through unchanged.
String _downsampleString(String s, ColorProfile profile) {
  if (profile == ColorProfile.trueColor) return s;
  if (profile == ColorProfile.ascii) {
    // Strip all ANSI sequences for ASCII profile
    final segments = parseAnsiSegments(s);
    final buf = StringBuffer();
    for (final seg in segments) {
      if (!seg.isAnsi) buf.write(seg.text);
    }
    return buf.toString();
  }

  // For ansi and ansi256 profiles, rewrite color parameters in SGR sequences
  final segments = parseAnsiSegments(s);
  final buf = StringBuffer();
  for (final seg in segments) {
    if (!seg.isAnsi) {
      buf.write(seg.text);
      continue;
    }
    final seq = seg.text;
    if (!seq.startsWith('\x1b[') || !seq.endsWith('m')) {
      buf.write(seq);
      continue;
    }
    // Parse SGR params and rewrite colors
    final inner = seq.substring(2, seq.length - 1);
    final params = inner.split(';');
    final newParams = <String>[];
    var i = 0;
    while (i < params.length) {
      final p = params[i];
      if ((p == '38' || p == '48') && i + 1 < params.length) {
        final type = params[i + 1];
        if (type == '2' && i + 4 < params.length) {
          // RGB color: 38;2;r;g;b or 48;2;r;g;b
          final r = int.tryParse(params[i + 2]) ?? 0;
          final g = int.tryParse(params[i + 3]) ?? 0;
          final b = int.tryParse(params[i + 4]) ?? 0;
          final rgb = RGBColor(r, g, b);
          final down = downsample(rgb, profile);
          _addColorParams(newParams, p == '38', down);
          i += 5;
          continue;
        } else if (type == '5' && i + 2 < params.length) {
          // 256 color: 38;5;n or 48;5;n
          final n = int.tryParse(params[i + 2]) ?? 0;
          final c = n < 16 ? ANSIColor(n) : ANSI256Color(n);
          final down = downsample(c, profile);
          _addColorParams(newParams, p == '38', down);
          i += 3;
          continue;
        }
      }
      newParams.add(p);
      i++;
    }
    if (newParams.isEmpty) {
      buf.write('\x1b[m');
    } else {
      buf.write('\x1b[${newParams.join(';')}m');
    }
  }
  return buf.toString();
}

void _addColorParams(List<String> params, bool isFg, LipglossColor c) {
  switch (c) {
    case NoColor():
      break;
    case ANSIColor():
      final base = isFg ? 30 : 40;
      if (c.value < 8) {
        params.add('${base + c.value}');
      } else {
        params.add('${base + 60 + c.value - 8}');
      }
    case ANSI256Color():
      params.addAll([isFg ? '38' : '48', '5', '${c.value}']);
    case RGBColor():
      params.addAll([isFg ? '38' : '48', '2', '${c.r}', '${c.g}', '${c.b}']);
  }
}

/// Print with auto-downsampled colors.
void lipPrintln(Object? v) {
  final profile = detectColorProfile();
  print(_downsampleString(v.toString(), profile));
}

/// Print without trailing newline, with auto-downsampled colors.
void lipPrint(Object? v) {
  final profile = detectColorProfile();
  stdout.write(_downsampleString(v.toString(), profile));
}

/// Sprint: returns a string with auto-downsampled colors.
String lipSprint(Object? v) {
  final profile = detectColorProfile();
  return _downsampleString(v.toString(), profile);
}

/// Sprintln: returns a string with newline, with auto-downsampled colors.
String lipSprintln(Object? v) {
  final profile = detectColorProfile();
  return '${_downsampleString(v.toString(), profile)}\n';
}

/// Sprintf: format and return with auto-downsampled colors.
/// Supports %s, %d, %f, %v (all replaced with toString).
String lipSprintf(String fmt, List<Object?> args) {
  final profile = detectColorProfile();
  return _downsampleString(_simpleFmt(fmt, args), profile);
}

/// Fprint: write to a specific sink with auto-downsampled colors.
void lipFprint(IOSink sink, Object? v) {
  final profile = detectColorProfile(sink);
  sink.write(_downsampleString(v.toString(), profile));
}

/// Fprintln: write with newline to a specific sink with auto-downsampled colors.
void lipFprintln(IOSink sink, Object? v) {
  final profile = detectColorProfile(sink);
  sink.writeln(_downsampleString(v.toString(), profile));
}

/// Fprintf: format and write to a specific sink with auto-downsampled colors.
void lipFprintf(IOSink sink, String fmt, List<Object?> args) {
  final profile = detectColorProfile(sink);
  sink.write(_downsampleString(_simpleFmt(fmt, args), profile));
}

/// Simple Go-style format string replacement.
/// Supports %s, %d, %f, %v, %x, %o, %b, %% (escape).
String _simpleFmt(String fmt, List<Object?> args) {
  final buf = StringBuffer();
  var argIdx = 0;
  var i = 0;
  while (i < fmt.length) {
    if (fmt[i] == '%' && i + 1 < fmt.length) {
      final spec = fmt[i + 1];
      if (spec == '%') {
        buf.write('%');
        i += 2;
        continue;
      }
      if (argIdx < args.length) {
        final arg = args[argIdx++];
        switch (spec) {
          case 's':
          case 'v':
            buf.write(arg.toString());
          case 'd':
            buf.write(
                (arg is num ? arg.toInt() : int.tryParse(arg.toString()) ?? arg)
                    .toString());
          case 'f':
            buf.write((arg is num
                    ? arg.toDouble()
                    : double.tryParse(arg.toString()) ?? arg)
                .toString());
          case 'x':
            final n = arg is int ? arg : int.tryParse(arg.toString());
            buf.write(n != null ? n.toRadixString(16) : arg.toString());
          case 'o':
            final n = arg is int ? arg : int.tryParse(arg.toString());
            buf.write(n != null ? n.toRadixString(8) : arg.toString());
          case 'b':
            final n = arg is int ? arg : int.tryParse(arg.toString());
            buf.write(n != null ? n.toRadixString(2) : arg.toString());
          default:
            buf.write('%$spec');
        }
      } else {
        buf.write('%$spec');
      }
      i += 2;
    } else {
      buf.write(fmt[i]);
      i++;
    }
  }
  return buf.toString();
}

/// Complete: returns a function that selects the appropriate color for the profile.
typedef CompleteFunc = LipglossColor Function({
  LipglossColor trueColor,
  LipglossColor ansi256,
  LipglossColor ansi,
});

/// Create a Complete function for the given color profile.
CompleteFunc complete(ColorProfile profile) {
  return ({
    LipglossColor trueColor = const NoColor(),
    LipglossColor ansi256 = const NoColor(),
    LipglossColor ansi = const NoColor(),
  }) {
    switch (profile) {
      case ColorProfile.trueColor:
        return trueColor;
      case ColorProfile.ansi256:
        return ansi256;
      case ColorProfile.ansi:
        return ansi;
      case ColorProfile.ascii:
        return const NoColor();
    }
  };
}
