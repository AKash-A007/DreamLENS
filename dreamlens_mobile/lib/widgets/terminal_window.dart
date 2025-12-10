import 'package:flutter/material.dart';

class TerminalWindow extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showControls;

  const TerminalWindow({
    super.key,
    required this.title,
    required this.child,
    this.showControls = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF00FF00), width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF00).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF00).withOpacity(0.1),
              border: const Border(
                bottom: BorderSide(color: Color(0xFF00FF00), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '// $title',
                  style: const TextStyle(
                    color: Color(0xFF00FF00),
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                if (showControls) _buildTerminalControls(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalControls() {
    return Row(
      children: [
        _buildControlButton(color: Colors.red),
        const SizedBox(width: 6),
        _buildControlButton(color: Colors.yellow),
        const SizedBox(width: 6),
        _buildControlButton(color: Colors.green),
      ],
    );
  }

  Widget _buildControlButton({required Color color}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }
}