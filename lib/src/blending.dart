// Ported from charmbracelet/lipgloss blending.go
// Original: https://github.com/charmbracelet/lipgloss
// Licensed under MIT by Charmbracelet, Inc.

import 'dart:math' as math;

import 'color.dart';

/// Blend a 1D gradient between color stops over [steps] increments.
List<LipglossColor> blend1D(int steps, List<LipglossColor> stops) {
  if (stops.isEmpty) return [];
  if (stops.length == 1) return List.filled(steps, stops.first);
  if (steps <= 0) return [];
  if (steps == 1) return [stops.first];

  final result = <LipglossColor>[];
  final segmentSize = (steps - 1) / (stops.length - 1);

  for (var i = 0; i < steps; i++) {
    final segmentIdx = i / segmentSize;
    final fromIdx = segmentIdx.floor().clamp(0, stops.length - 2);
    final toIdx = fromIdx + 1;
    final t = segmentIdx - fromIdx;

    result.add(_blendLab(stops[fromIdx], stops[toIdx], t));
  }

  return result;
}

/// Blend a 2D gradient grid.
List<LipglossColor> blend2D(
  int width,
  int height,
  double angle,
  List<LipglossColor> stops,
) {
  if (stops.isEmpty || width <= 0 || height <= 0) return [];

  // Generate 1D gradient along the angle axis
  final diagonal = math.sqrt((width * width + height * height).toDouble());
  final gradientLength = diagonal.ceil();
  final gradient = blend1D(gradientLength, stops);

  final result = <LipglossColor>[];
  final radians = angle * math.pi / 180.0;
  final cosA = math.cos(radians);
  final sinA = math.sin(radians);

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      // Project (x, y) onto the gradient direction
      final nx = x / width;
      final ny = y / height;
      final projectedPos = (nx * cosA + ny * sinA + 1.0) / 2.0;
      final idx = (projectedPos * (gradient.length - 1))
          .round()
          .clamp(0, gradient.length - 1);
      result.add(gradient[idx]);
    }
  }

  return result;
}

/// Blend two colors in CIELAB space.
LipglossColor _blendLab(LipglossColor c1, LipglossColor c2, double t) {
  final lab1 = _rgbToLab(c1.rgba.r, c1.rgba.g, c1.rgba.b);
  final lab2 = _rgbToLab(c2.rgba.r, c2.rgba.g, c2.rgba.b);

  final L = lab1.$1 + (lab2.$1 - lab1.$1) * t;
  final a = lab1.$2 + (lab2.$2 - lab1.$2) * t;
  final b = lab1.$3 + (lab2.$3 - lab1.$3) * t;

  final rgb = _labToRgb(L, a, b);
  return RGBColor(rgb.$1, rgb.$2, rgb.$3);
}

// ─── CIELAB Color Space Conversion ───

(double, double, double) _rgbToLab(int r, int g, int b) {
  // RGB → XYZ (sRGB, D65)
  var rn = r / 255.0;
  var gn = g / 255.0;
  var bn = b / 255.0;

  rn = rn > 0.04045
      ? math.pow((rn + 0.055) / 1.055, 2.4).toDouble()
      : rn / 12.92;
  gn = gn > 0.04045
      ? math.pow((gn + 0.055) / 1.055, 2.4).toDouble()
      : gn / 12.92;
  bn = bn > 0.04045
      ? math.pow((bn + 0.055) / 1.055, 2.4).toDouble()
      : bn / 12.92;

  final x = (rn * 0.4124564 + gn * 0.3575761 + bn * 0.1804375) / 0.950456;
  final y = rn * 0.2126729 + gn * 0.7151522 + bn * 0.0721750;
  final z = (rn * 0.0193339 + gn * 0.1191920 + bn * 0.9503041) / 1.089058;

  // XYZ → Lab
  final fx = x > 0.008856
      ? math.pow(x, 1.0 / 3.0).toDouble()
      : (7.787 * x) + 16.0 / 116.0;
  final fy = y > 0.008856
      ? math.pow(y, 1.0 / 3.0).toDouble()
      : (7.787 * y) + 16.0 / 116.0;
  final fz = z > 0.008856
      ? math.pow(z, 1.0 / 3.0).toDouble()
      : (7.787 * z) + 16.0 / 116.0;

  final L = (116.0 * fy) - 16.0;
  final a = 500.0 * (fx - fy);
  final bLab = 200.0 * (fy - fz);

  return (L, a, bLab);
}

(int, int, int) _labToRgb(double L, double a, double bLab) {
  // Lab → XYZ
  final fy = (L + 16.0) / 116.0;
  final fx = a / 500.0 + fy;
  final fz = fy - bLab / 200.0;

  final x =
      (fx * fx * fx > 0.008856 ? fx * fx * fx : (fx - 16.0 / 116.0) / 7.787) *
          0.950456;
  final y = L > 7.9996 ? fy * fy * fy : L / 903.3;
  final z =
      (fz * fz * fz > 0.008856 ? fz * fz * fz : (fz - 16.0 / 116.0) / 7.787) *
          1.089058;

  // XYZ → sRGB
  var rn = x * 3.2404542 + y * -1.5371385 + z * -0.4985314;
  var gn = x * -0.9692660 + y * 1.8760108 + z * 0.0415560;
  var bn = x * 0.0556434 + y * -0.2040259 + z * 1.0572252;

  rn = rn > 0.0031308 ? 1.055 * math.pow(rn, 1.0 / 2.4) - 0.055 : 12.92 * rn;
  gn = gn > 0.0031308 ? 1.055 * math.pow(gn, 1.0 / 2.4) - 0.055 : 12.92 * gn;
  bn = bn > 0.0031308 ? 1.055 * math.pow(bn, 1.0 / 2.4) - 0.055 : 12.92 * bn;

  return (
    (rn * 255.0).round().clamp(0, 255),
    (gn * 255.0).round().clamp(0, 255),
    (bn * 255.0).round().clamp(0, 255),
  );
}
