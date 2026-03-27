import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for HapticFeedback

class BouncyCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isDisabled;
  final double scaleRatio; // How much it shrinks (default 0.95)

  const BouncyCard({
    super.key,
    required this.child,
    required this.onTap,
    this.isDisabled = false,
    this.scaleRatio = 0.95,
  });

  @override
  State<BouncyCard> createState() => _BouncyCardState();
}

class _BouncyCardState extends State<BouncyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Fast snap effect
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isDisabled) {
          HapticFeedback.lightImpact(); // 📳 Haptic vibration
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (!widget.isDisabled) {
          _controller.reverse();
          widget.onTap?.call();
        }
      },
      onTapCancel: () {
        if (!widget.isDisabled) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - (_controller.value * (1.0 - widget.scaleRatio));
          return Transform.scale(
            scale: scale,
            child: widget.child,
          );
        },
      ),
    );
  }
}