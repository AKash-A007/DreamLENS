import 'package:flutter/material.dart';
import '../widgets/terminal_window.dart';
import '../widgets/metric_card.dart';
import '../widgets/matrix_rain.dart';
import 'generation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isGenerating = false;
  String _status = 'SYSTEM ONLINE';
  double _accuracy = 87.2;
  double _cosineSim = 0.7132;
  double _l2Distance = 4.812;
  double _pearsonR = 0.6124;

  @override
  void initState() {
    super.initState();
    _animateStatus();
  }

  void _animateStatus() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _status = 'SYNCHRONIZING...';
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _status = 'SYSTEM ONLINE';
            });
            _animateStatus();
          }
        });
      }
    });
  }

  void _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _status = 'GENERATING IMAGE...';
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _accuracy = 85 + (15 * (DateTime.now().millisecond % 100) / 100);
      _cosineSim = 0.6 + (0.3 * (DateTime.now().second % 100) / 100);
      _l2Distance = 4 + (2 * (DateTime.now().millisecond % 100) / 100);
      _pearsonR = 0.5 + (0.3 * (DateTime.now().second % 100) / 100);
      _isGenerating = false;
      _status = 'SYSTEM ONLINE';
    });

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenerationScreen(
            accuracy: _accuracy,
            cosineSim: _cosineSim,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: MatrixRain(),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TerminalWindow(
                      title: 'DREAMLENS v2.4.1',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NEURAL INTERFACE // EEG-TO-IMAGE SYNTHESIS',
                            style: TextStyle(
                              color: Color(0xFF00FF00),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'STATUS: $_status',
                            style: TextStyle(
                              color: _status.contains('ONLINE')
                                  ? const Color(0xFF00FF00)
                                  : Colors.yellow,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        MetricCard(
                          label: 'TOP-1 ACCURACY',
                          value: '${_accuracy.toStringAsFixed(2)}%',
                          color: const Color(0xFF00FF00),
                        ),
                        MetricCard(
                          label: 'COSINE SIM',
                          value: _cosineSim.toStringAsFixed(4),
                          color: const Color(0xFF00FF00),
                        ),
                        MetricCard(
                          label: 'L2 DISTANCE',
                          value: _l2Distance.toStringAsFixed(3),
                          color: const Color(0xFF00FF00),
                        ),
                        MetricCard(
                          label: 'PEARSON R',
                          value: _pearsonR.toStringAsFixed(4),
                          color: const Color(0xFF00FF00),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TerminalWindow(
                      title: 'CONTROL PANEL',
                      child: Column(
                        children: [
                          _buildControlButton(
                            icon: Icons.play_arrow,
                            label: 'START GENERATION',
                            onPressed: _startGeneration,
                            isActive: !_isGenerating,
                          ),
                          const SizedBox(height: 12),
                          _buildControlButton(
                            icon: Icons.analytics,
                            label: 'VIEW METRICS',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TerminalWindow(
                      title: 'PROCESSING PIPELINE',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPipelineStep('EEG INPUT', true),
                          _buildPipelineStep('PREPROCESSING', true),
                          _buildPipelineStep('FEATURE EXTRACTION', true),
                          _buildPipelineStep('CLIP EMBEDDING', true),
                          _buildPipelineStep('DIFFUSION', _isGenerating),
                          _buildPipelineStep('OUTPUT', false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF00FF00),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: isActive ? const Color(0xFF00FF00) : Colors.grey,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStep(String step, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00FF00) : Colors.grey,
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00FF00).withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
          ),
          Text(
            '> $step',
            style: TextStyle(
              color: isActive ? const Color(0xFF00FF00) : Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}