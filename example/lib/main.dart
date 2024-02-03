import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:path_smoother/path_smoother.dart';

void main() {
  final smoothPath = PathSmoother.generateSmoothPath(
    cornerRadius: 8,
    points: [
      const Offset(0, 0),
      const Offset(0, 100),
      const Offset(100, 0),
    ],
  );

  log('Smooth path: $smoothPath');
}
