import 'package:flutter_test/flutter_test.dart';
import 'package:path_smoother/path_smoother.dart';

void main() {
  group('generateSmoothPath', () {
    test('returns an empty path for less than 3 points', () {
      final path = PathSmoother.generateSmoothPath(
        points: [const Offset(0, 0), const Offset(1, 1)],
        cornerRadius: 1.0,
      );

      final metrics = path.computeMetrics();
      expect(metrics.length, 0);
    });

    test('returns a non-empty path for 3 or more points', () {
      final path = PathSmoother.generateSmoothPath(
        points: [const Offset(0, 0), const Offset(1, 1), const Offset(2, 2)],
        cornerRadius: 1.0,
      );

      final metrics = path.computeMetrics();
      expect(metrics.length, greaterThan(0));
    });

    test('returns a closed path when isClosed is true', () {
      final path = PathSmoother.generateSmoothPath(
        points: [const Offset(0, 0), const Offset(1, 1), const Offset(2, 2)],
        cornerRadius: 1.0,
        isClosed: true,
      );

      final metrics = path.computeMetrics();
      expect(metrics.firstOrNull?.isClosed, isTrue);
    });

    test('returns an open path when isClosed is false', () {
      final path = PathSmoother.generateSmoothPath(
        points: [const Offset(0, 0), const Offset(1, 1), const Offset(2, 2)],
        cornerRadius: 1.0,
        isClosed: false,
      );

      final metrics = path.computeMetrics();
      expect(metrics.firstOrNull?.isClosed, isFalse);
    });
  });

  group('arePointsArrangedClockwise', () {
    test('returns true for clockwise points', () {
      final result = PathSmoother.arePointsArrangedClockwise(
        const Offset(0, 0),
        const Offset(1, 1),
        const Offset(2, 0),
      );

      expect(result, isFalse);
    });

    test('returns false for counter-clockwise points', () {
      final result = PathSmoother.arePointsArrangedClockwise(
        const Offset(0, 0),
        const Offset(1, 1),
        const Offset(0, 2),
      );

      expect(result, isTrue);
    });
  });

  group('findCircleIntersections', () {
    test('returns correct intersection points', () {
      final result = PathSmoother.findCircleIntersections(
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(10, 10),
        2.0,
      );

      expect(result.first.dx, moreOrLessEquals(8));
      expect(result.first.dy, moreOrLessEquals(0));
      expect(result.second.dx, moreOrLessEquals(10));
      expect(result.second.dy, moreOrLessEquals(2));
    });
  });
}
