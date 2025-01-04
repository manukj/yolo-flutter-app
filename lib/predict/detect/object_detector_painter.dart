import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/predict/detect/detected_object.dart';

/// A painter used to draw the detected objects on the screen.
class ObjectDetectorPainter extends CustomPainter {
  /// Creates a [ObjectDetectorPainter].
  ObjectDetectorPainter(
    this._detectionResults, [
    this._strokeWidth = 3.0,
  ]);

  final List<DetectedObject> _detectionResults;
  final double _strokeWidth;

  // Define a map of label colors
  final Map<int, Color> _labelColors = {
    0: Colors.red,
    1: Colors.green,
    2: Colors.blue,
    3: Colors.orange,
    4: Colors.purple,
    5: Colors.yellow,
    6: Colors.pink,
    7: Colors.teal,
    8: Colors.cyan,
    9: Colors.indigo,
    10: Colors.lime,
    11: Colors.brown,
    12: Colors.amber,
    13: Colors.lightGreen,
    14: Colors.lightBlue,
    15: Colors.deepOrange,
    16: Colors.deepPurple,
    17: Colors.grey,
    18: Colors.black,
    19: Colors.blueGrey,
    20: Colors.redAccent,
    21: Colors.greenAccent,
    22: Colors.blueAccent,
    23: Colors.orangeAccent,
    24: Colors.purpleAccent,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    for (final detectedObject in _detectionResults) {
      final left = detectedObject.boundingBox.left;
      final top = detectedObject.boundingBox.top;
      final width = detectedObject.boundingBox.width;
      final height = detectedObject.boundingBox.height;

      // Get color for the label
      final color = _labelColors[detectedObject.index] ?? Colors.black;

      // Draw bounding box with shadow
      canvas.drawShadow(
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(left, top, width, height),
              const Radius.circular(12),
            ),
          ),
        color.withOpacity(0.5),
        4.0,
        true,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, width, height),
          const Radius.circular(12),
        ),
        borderPaint..color = color.withOpacity(0.8),
      );

      // Create the label text
      final label =
          '${detectedObject.label} (${(detectedObject.confidence * 100).toStringAsFixed(1)}%)';

      // Measure the text width and height
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textWidth = textPainter.width;
      final textHeight = textPainter.height;

      // Ensure the background rect fits the text and add padding
      final labelPadding = 8.0;
      final labelRectWidth = textWidth + labelPadding * 2;
      final labelRectHeight = textHeight + labelPadding * 2;

      // Draw Label Background with gradient
      final labelRect = Rect.fromLTWH(
        left, // Align with bounding box
        max(0, top - labelRectHeight), // Position above the bounding box
        labelRectWidth,
        labelRectHeight,
      );

      final labelGradient = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(labelRect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(8)),
        labelGradient,
      );

      // Draw the text with a shadow
      final textOffset = Offset(
        labelRect.left + labelPadding,
        labelRect.top + labelPadding,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
