import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/terminal_window.dart';
import '../utils/sample_data.dart';

class GenerationScreen extends StatefulWidget {
  final double accuracy;
  final double cosineSim;

  const GenerationScreen({
    super.key,
    required this.accuracy,
    required this.cosineSim,
  });

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  final GlobalKey _imageKey = GlobalKey();
  bool _isGenerating = true;
  List<double> _embedding = [];
  late Uint8List _imageData;

  @override
  void initState() {
    super.initState();
    _initializeGeneration();
  }

  void _initializeGeneration() async {
    // Use sample EEG tensor data
    _embedding = SampleData.sampleEEGTensor;
    
    // Load sample cat image
    _imageData = SampleData.generateSampleCatImage();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _saveImage() async {
    try {
      final RenderRepaintBoundary boundary =
          _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDocDir.path}/dreamlens_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image saved successfully',
              style: TextStyle(
                color: Color(0xFF00FF00),
              ),
            ),
            backgroundColor: Colors.black,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving image: $e');
    }
  }

  Future<void> _shareImage() async {
    try {
      final RenderRepaintBoundary boundary =
          _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File(
              '${tempDir.path}/dreamlens_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Generated from DreamLENS EEG-to-Image',
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  Widget _buildGeneratedImage() {
    return Container(
      width: 256,
      height: 256,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00FF00), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF00).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(
        painter: EEGImagePainter(_embedding, _isGenerating),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'IMAGE GENERATION',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF00)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF00FF00)),
            onPressed: _isGenerating ? null : _saveImage,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF00FF00)),
            onPressed: _isGenerating ? null : _shareImage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: RepaintBoundary(
                  key: _imageKey,
                  child: _buildGeneratedImage(),
                ),
              ),
              const SizedBox(height: 24),
              TerminalWindow(
                title: 'EEG EMBEDDING DATA',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIMENSIONS: ${_embedding.length}',
                      style: const TextStyle(
                        color: Color(0xFF00FF00),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MEAN: ${_embedding.isNotEmpty ? (_embedding.reduce((a, b) => a + b) / _embedding.length).toStringAsFixed(6) : "0.000000"}',
                      style: const TextStyle(
                        color: Color(0xFF008800),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'STD DEV: ${_embedding.isNotEmpty ? _calculateStdDev().toStringAsFixed(6) : "0.000000"}',
                      style: const TextStyle(
                        color: Color(0xFF008800),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TerminalWindow(
                title: 'GENERATION METRICS',
                child: Column(
                  children: [
                    _buildMetricRow(
                        'Accuracy:', '${widget.accuracy.toStringAsFixed(2)}%'),
                    _buildMetricRow('Cosine Similarity:',
                        widget.cosineSim.toStringAsFixed(4)),
                    _buildMetricRow('Processing Time:', '2.4s'),
                    _buildMetricRow('Resolution:', '256×256'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TerminalWindow(
                title: 'EMBEDDING MATRIX',
                child: SizedBox(
                  height: 120,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final value = _embedding.isNotEmpty
                          ? _embedding[index % _embedding.length]
                          : 0.0;
                      return Container(
                        color: Color.fromRGBO(
                          0,
                          (255 * value.abs()).toInt().clamp(0, 255),
                          0,
                          0.8,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF008800),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateStdDev() {
    if (_embedding.isEmpty) return 0.0;
    final mean = _embedding.reduce((a, b) => a + b) / _embedding.length;
    final variance =
        _embedding.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
            _embedding.length;
    return sqrt(variance);
  }
}

class EEGImagePainter extends CustomPainter {
  final List<double> embedding;
  final bool isGenerating;

  EEGImagePainter(this.embedding, this.isGenerating);

  @override
  void paint(Canvas canvas, Size size) {
    if (isGenerating) {
      _drawLoading(canvas, size);
    } else {
      _drawEEGImage(canvas, size);
    }
  }

  void _drawLoading(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'GENERATING...',
        style: TextStyle(
          color: Color(0xFF00FF00),
          fontSize: 20,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawEEGImage(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < size.height.toInt(); y++) {
      for (int x = 0; x < size.width.toInt(); x++) {
        double intensity = 0.0;

        for (int i = 0; i < min(8, embedding.length ~/ 64); i++) {
          final idx = (i * 64) % embedding.length;
          final v = embedding[idx];
          final freq = v.abs() * 20;
          intensity += 0.125 *
              (sin(x * freq * 0.01 + y * freq * 0.015 + v * pi) + 1) /
              2;
        }

        // Add cat-like pattern
        final centerX = size.width / 2;
        final centerY = size.height / 2;
        final dx = (x - centerX) / size.width;
        final dy = (y - centerY) / size.height;
        final dist = sqrt(dx * dx + dy * dy);
        
        // Create cat ears
        if (dy < -0.2 && dy > -0.4) {
          if ((dx > 0.2 && dx < 0.35) || (dx < -0.2 && dx > -0.35)) {
            intensity += 0.3;
          }
        }
        
        // Create cat face
        if (dist < 0.3) {
          intensity += 0.2;
        }

        intensity = intensity.clamp(0.0, 1.0);

        paint.color = Color.fromRGBO(
          0,
          (255 * intensity).toInt().clamp(0, 255),
          0,
          1.0,
        );

        canvas.drawRect(
          Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}