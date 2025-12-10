import 'dart:math';
import 'dart:typed_data';

class SampleData {
  // Sample EEG Tensor (512-dimensional embedding)
  // Simulates real EEG brain wave patterns from different frequency bands
  static final List<double> sampleEEGTensor = _generateEEGTensor();

  static List<double> _generateEEGTensor() {
    final List<double> tensor = [];
    final random = Random(42); // Fixed seed for reproducibility

    // Generate 512-dimensional tensor simulating EEG patterns
    for (int i = 0; i < 512; i++) {
      // Mix of different frequency components (alpha, beta, theta, delta waves)
      double value = 0.0;

      // Delta waves (0.5-4 Hz) - deep sleep patterns
      value += 0.3 * sin(i * 0.02 + random.nextDouble() * pi);

      // Theta waves (4-8 Hz) - drowsiness, meditation
      value += 0.25 * sin(i * 0.05 + random.nextDouble() * pi);

      // Alpha waves (8-13 Hz) - relaxed, calm
      value += 0.25 * sin(i * 0.1 + random.nextDouble() * pi);

      // Beta waves (13-30 Hz) - active thinking
      value += 0.15 * sin(i * 0.2 + random.nextDouble() * pi);

      // Gamma waves (30-100 Hz) - cognitive processing
      value += 0.05 * sin(i * 0.4 + random.nextDouble() * pi);

      // Add some noise
      value += (random.nextDouble() - 0.5) * 0.1;

      // Normalize to [-1, 1] range
      tensor.add(value.clamp(-1.0, 1.0));
    }

    return tensor;
  }

  // Generate a sample cat image pattern (256x256 pixels as green values)
  static Uint8List generateSampleCatImage() {
    final int width = 256;
    final int height = 256;
    final Uint8List imageData = Uint8List(width * height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = y * width + x;
        double intensity = 0.0;

        // Center coordinates
        final double centerX = width / 2;
        final double centerY = height / 2;
        final double dx = (x - centerX) / width;
        final double dy = (y - centerY) / height;
        final double dist = sqrt(dx * dx + dy * dy);

        // Cat head (circular shape)
        if (dist < 0.35) {
          intensity = 0.6 - dist * 0.5;
        }

        // Cat ears (triangular shapes)
        // Left ear
        if (dy < -0.15 && dy > -0.4 && dx > 0.15 && dx < 0.35) {
          final double earIntensity = 1.0 - (dy.abs() - 0.15) / 0.25;
          intensity = max(intensity, earIntensity * 0.7);
        }
        // Right ear
        if (dy < -0.15 && dy > -0.4 && dx < -0.15 && dx > -0.35) {
          final double earIntensity = 1.0 - (dy.abs() - 0.15) / 0.25;
          intensity = max(intensity, earIntensity * 0.7);
        }

        // Cat eyes
        // Left eye
        final double leftEyeX = -0.12;
        final double leftEyeY = -0.05;
        final double leftEyeDist =
            sqrt(pow(dx - leftEyeX, 2) + pow(dy - leftEyeY, 2));
        if (leftEyeDist < 0.05) {
          intensity = 0.9;
        }
        // Right eye
        final double rightEyeX = 0.12;
        final double rightEyeY = -0.05;
        final double rightEyeDist =
            sqrt(pow(dx - rightEyeX, 2) + pow(dy - rightEyeY, 2));
        if (rightEyeDist < 0.05) {
          intensity = 0.9;
        }

        // Cat nose (small triangle)
        if (dy > 0.05 && dy < 0.12 && dx.abs() < 0.04) {
          intensity = 0.8;
        }

        // Cat mouth (smile)
        if (dy > 0.12 && dy < 0.18) {
          final double mouthCurve = 0.15 * sin((dx * 5));
          if ((dy - 0.15).abs() < 0.02 && dx.abs() < 0.15) {
            intensity = max(intensity, 0.7);
          }
        }

        // Cat whiskers
        if (dy.abs() < 0.01 && dx.abs() > 0.2 && dx.abs() < 0.45) {
          intensity = max(intensity, 0.5);
        }

        // Add texture and noise
        final double noise = (sin(x * 0.5) * cos(y * 0.5) + 1) / 2;
        intensity = (intensity * 0.9 + noise * 0.1).clamp(0.0, 1.0);

        // Convert to 8-bit value
        imageData[index] = (intensity * 255).toInt().clamp(0, 255);
      }
    }

    return imageData;
  }

  // Sample tensor statistics
  static Map<String, double> getTensorStats() {
    final double mean =
        sampleEEGTensor.reduce((a, b) => a + b) / sampleEEGTensor.length;
    final double variance = sampleEEGTensor
            .map((x) => pow(x - mean, 2))
            .reduce((a, b) => a + b) /
        sampleEEGTensor.length;
    final double stdDev = sqrt(variance);
    final double minVal =
        sampleEEGTensor.reduce((a, b) => a < b ? a : b);
    final double maxVal =
        sampleEEGTensor.reduce((a, b) => a > b ? a : b);

    return {
      'mean': mean,
      'std_dev': stdDev,
      'min': minVal,
      'max': maxVal,
      'dimensions': sampleEEGTensor.length.toDouble(),
    };
  }

  // Print tensor information (for debugging)
  static String getTensorInfo() {
    final stats = getTensorStats();
    return '''
EEG TENSOR INFORMATION:
-----------------------
Dimensions: ${stats['dimensions']!.toInt()}
Mean: ${stats['mean']!.toStringAsFixed(6)}
Std Dev: ${stats['std_dev']!.toStringAsFixed(6)}
Min: ${stats['min']!.toStringAsFixed(6)}
Max: ${stats['max']!.toStringAsFixed(6)}

Sample values (first 10):
${sampleEEGTensor.take(10).map((v) => v.toStringAsFixed(4)).join(', ')}
    ''';
  }
}