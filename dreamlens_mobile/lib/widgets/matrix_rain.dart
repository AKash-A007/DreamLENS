import 'dart:math';
import 'package:flutter/material.dart';

class MatrixRain extends StatefulWidget {
  const MatrixRain({super.key});

  @override
  State<MatrixRain> createState() => _MatrixRainState();
}

class _MatrixRainState extends State<MatrixRain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<RainDrop> _drops = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: MatrixPainter(_drops, MediaQuery.of(context).size),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class MatrixPainter extends CustomPainter {
  final List<RainDrop> drops;
  final Size screenSize;

  MatrixPainter(this.drops, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) {
      final random = Random();
      for (int i = 0; i < size.width ~/ 20; i++) {
        drops.add(RainDrop(
          x: i * 20.0,
          y: random.nextDouble() * -size.height,
          speed: 2 + random.nextDouble() * 5,
          length: 10 + random.nextInt(20),
        ));
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withOpacity(0.05),
    );

    for (final drop in drops) {
      drop.update(size);
      drop.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RainDrop {
  double x;
  double y;
  double speed;
  int length;
  final List<String> chars;
  static const String charSet = '01アイウエオカキクケコサシスセソ';

  RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
  }) : chars = List.generate(
          length,
          (_) => charSet[Random().nextInt(charSet.length)],
        );

  void update(Size size) {
    y += speed;
    if (y > size.height + length * 20) {
      y = Random().nextDouble() * -100;
      speed = 2 + Random().nextDouble() * 5;
    }
  }

  void draw(Canvas canvas) {
    const textStyle = TextStyle(
      color: Color(0xFF00FF00),
      fontSize: 16,
    );

    for (int i = 0; i < chars.length; i++) {
      final alpha = (chars.length - i) / chars.length;
      final textPainter = TextPainter(
        text: TextSpan(
          text: chars[i],
          style: textStyle.copyWith(
            color: const Color(0xFF00FF00).withOpacity(alpha * 0.7),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      final yPos = y - i * 20;
      if (yPos > -20 && yPos < 2000) {
        textPainter.paint(canvas, Offset(x, yPos));
      }
    }
  }
}