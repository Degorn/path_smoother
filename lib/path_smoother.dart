library path_smoother;

import 'dart:math';
import 'dart:ui';

abstract class PathSmoother {
  static Path generateSmoothPath({
    required List<Offset> points,
    required double cornerRadius,
    bool isClosed = true,
  }) {
    final path = Path();

    if (points.length < 3) {
      assert(true, 'Points must be at least 3');
      return path;
    }

    final pathPoints = [
      if (isClosed) (points.first + points.last) / 2,
      ...points,
      points.first,
    ];

    path.moveTo(pathPoints.first.dx, pathPoints.first.dy);

    for (var i = 0; i < pathPoints.length - 2; i++) {
      final cornerPoint = pathPoints[i + 1];

      if (i == pathPoints.length - 3 && !isClosed) {
        path.lineTo(cornerPoint.dx, cornerPoint.dy);
        break;
      }

      final startPoint = pathPoints[i];
      final endPoint = pathPoints[i + 2];

      path.roundCornerToPoint(
        startPoint: startPoint,
        cornerPoint: cornerPoint,
        endPoint: endPoint,
        cornerRadius: cornerRadius,
      );
    }

    if (isClosed) {
      path.close();
    }

    return path;
  }

  static bool arePointsArrangedClockwise(Offset pointA, Offset pointB, Offset pointC) {
    final area = 0.5 *
        (-pointB.dy * pointC.dx +
            pointA.dy * (-pointB.dx + pointC.dx) +
            pointA.dx * (pointB.dy - pointC.dy) +
            pointB.dx * pointC.dy);
    return area > 0;
  }

  /// Finds the coordinates of the intersection points of an inscribed circle with lines formed by
  /// three points.
  ///
  /// The [p1], [p2], and [p3] represent three points that form an angle circumscribed around a
  /// circle. The [r] represents the radius of the inscribed circle.
  ///
  /// Returns a `Record` containing the calculated [first] and [second] coordinates.
  /// [first] - the intersection point of the `p1-p2` line with the circle.
  /// [second] - the intersection point of the `p2-p3` line with the circle.
  static ({Offset first, Offset second}) findCircleIntersections(
    Offset p1,
    Offset p2,
    Offset p3,
    double r,
  ) {
    // Path from the second point to the first and third points.
    var dx1 = p2.dx - p1.dx;
    var dy1 = p2.dy - p1.dy;
    var dx2 = p2.dx - p3.dx;
    var dy2 = p2.dy - p3.dy;

    // Distance from the second point to the first and third points.
    final d1 = sqrt(dx1 * dx1 + dy1 * dy1);
    final d2 = sqrt(dx2 * dx2 + dy2 * dy2);

    // Path normalization.
    dx1 /= d1;
    dy1 /= d1;
    dx2 /= d2;
    dy2 /= d2;

    // Calculating the angle between paths.
    final angle = acos(dx1 * dx2 + dy1 * dy2);

    // Calculating the distance from the second point to the intersection point.
    final dist = r / tan(angle / 2);

    // Calculation of intersection point coordinates.
    final x1 = p2.dx - dx1 * dist;
    final y1 = p2.dy - dy1 * dist;
    final x2 = p2.dx - dx2 * dist;
    final y2 = p2.dy - dy2 * dist;

    return (first: Offset(x1, y1), second: Offset(x2, y2));
  }
}

extension PathExtension on Path {
  void roundCornerToPoint({
    required Offset startPoint,
    required Offset cornerPoint,
    required Offset endPoint,
    required double cornerRadius,
  }) {
    final intersections = PathSmoother.findCircleIntersections(
      startPoint,
      cornerPoint,
      endPoint,
      cornerRadius,
    );

    if (intersections.first.isFinite) {
      lineTo(intersections.first.dx, intersections.first.dy);
    }

    if (intersections.second.isFinite) {
      arcToPoint(
        Offset(intersections.second.dx, intersections.second.dy),
        radius: Radius.circular(cornerRadius),
        clockwise: PathSmoother.arePointsArrangedClockwise(startPoint, cornerPoint, endPoint),
      );
    }
  }
}
