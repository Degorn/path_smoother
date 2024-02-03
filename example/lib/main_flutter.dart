import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_smoother/path_smoother.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      color: Colors.white,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _cornerRadius = 0.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Slider(
              value: _cornerRadius,
              min: 0,
              max: 40,
              onChanged: (value) {
                setState(() {
                  _cornerRadius = value;
                });
              },
            ),
            Row(
              children: [
                ShowcaseGroup(
                  isClosed: true,
                  points: const [
                    Offset(0, 0),
                    Offset(0, 100),
                    Offset(100, 0),
                  ],
                  cornerRadius: _cornerRadius,
                ),
                const SizedBox(width: 20),
                ShowcaseGroup(
                  isClosed: false,
                  points: const [
                    Offset(0, 0),
                    Offset(0, 100),
                    Offset(20, 0),
                    Offset(60, 60),
                    Offset(100, 20),
                  ],
                  cornerRadius: _cornerRadius,
                ),
                const SizedBox(width: 20),
                ShowcaseGroup(
                  isClosed: false,
                  points: const [
                    Offset(0, 0),
                    Offset(50, 30),
                    Offset(100, 0),
                  ],
                  cornerRadius: _cornerRadius,
                ),
                const SizedBox(width: 20),
                ShowcaseGroup(
                  isClosed: true,
                  points: const [
                    Offset(0, 0),
                    Offset(100, 0),
                    Offset(100, 100),
                    Offset(0, 100),
                  ],
                  cornerRadius: _cornerRadius,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShowcaseGroup extends StatelessWidget {
  const ShowcaseGroup({
    super.key,
    required this.points,
    required this.cornerRadius,
    required this.isClosed,
  });

  final List<Offset> points;
  final double cornerRadius;
  final bool isClosed;

  double slope(Offset p1, Offset p2) {
    if (p2.dx - p1.dx != 0.0) {
      return (p2.dy - p1.dy) / (p2.dx - p1.dx);
    } else {
      return double.infinity;
    }
  }

  Iterable<Offset> circleCenters() sync* {
    final pathPoints = isClosed
        ? [
            (points.first + points.last) / 2,
            ...points,
            points.first,
          ]
        : points;

    for (var i = 0; i < pathPoints.length - 2; i++) {
      final p1 = pathPoints[i];
      final p2 = pathPoints[i + 1];
      final p3 = pathPoints[i + 2];

      final intersections = PathSmoother.findCircleIntersections(
        p1,
        p2,
        p3,
        cornerRadius,
      );

      final isClockwise = PathSmoother.arePointsArrangedClockwise(p1, p2, p3);
      final point1 = isClockwise ? intersections.second : intersections.first;
      final point2 = isClockwise ? intersections.first : intersections.second;
      final distance = sqrt(pow(point2.dx - point1.dx, 2) + pow(point2.dy - point1.dy, 2));

      final midX = (point1.dx + point2.dx) / 2;
      final midY = (point1.dy + point2.dy) / 2;

      final deltaX = point2.dx - point1.dx;
      final deltaY = point2.dy - point1.dy;

      final h = sqrt(cornerRadius * cornerRadius - distance * distance / 4);

      final centerX = midX + h * deltaY / distance;
      final centerY = midY - h * deltaX / distance;

      yield Offset(centerX, centerY);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: CustomPaint(
          size: const Size(100, 100),
          painter: RoundedPathPainter(
            circleCenters: circleCenters().toList(),
            circleRadius: cornerRadius,
            path: PathSmoother.generateSmoothPath(
              cornerRadius: cornerRadius,
              isClosed: isClosed,
              points: points,
            ),
          ),
        ),
      ),
    );
  }
}

class CircleCenterCalculator {
  static Offset findCircleCenter(
    Offset p1,
    Offset p2,
    Offset p3,
    Offset intersection1,
    Offset intersection2,
    double cornerRadius,
  ) {
    Offset bisector = calculateBisector(p1, p2, p3);
    Offset normalizedBisector = normalizeVector(bisector);

    Offset averageIntersection = Offset(
      (intersection1.dx + intersection2.dx) / 2,
      (intersection1.dy + intersection2.dy) / 2,
    );

    Offset circleCenter = Offset(
      averageIntersection.dx - cornerRadius * normalizedBisector.dx,
      averageIntersection.dy - cornerRadius * normalizedBisector.dy,
    );

    return circleCenter;
  }

  static Offset calculateBisector(
    Offset p1,
    Offset p2,
    Offset p3,
  ) {
    Offset v1 = Offset(p1.dx - p2.dx, p1.dy - p2.dy);
    Offset v2 = Offset(p3.dx - p2.dx, p3.dy - p2.dy);

    Offset bisector = Offset(v1.dx + v2.dx, v1.dy + v2.dy);

    return bisector;
  }

  static Offset normalizeVector(Offset vector) {
    double magnitude = sqrt(vector.dx * vector.dx + vector.dy * vector.dy);
    return Offset(vector.dx / magnitude, vector.dy / magnitude);
  }
}

class RoundedPathPainter extends CustomPainter {
  const RoundedPathPainter({
    required this.path,
    this.circleCenters = const [],
    this.circleRadius,
  });

  final Path path;
  final List<Offset> circleCenters;
  final double? circleRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);

    for (final center in circleCenters) {
      canvas.drawCircle(
        center,
        circleRadius!,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(RoundedPathPainter oldDelegate) => path != oldDelegate.path;
}
