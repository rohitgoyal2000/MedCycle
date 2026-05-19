import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/theme.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final double height;
  final double borderRadius;
  final Widget? leading;
  final bool isLoading;
  final bool shimmerEffect;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient,
    this.height = 54,
    this.borderRadius = 14,
    this.leading,
    this.isLoading = false,
    this.shimmerEffect = false,
    this.textStyle,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppTheme.gradientMain;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Widget buttonContent = Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? LinearGradient(
                colors: gradient.colors
                    .map((c) => c.withValues(alpha: 0.5))
                    .toList(),
              )
            : gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: (gradient.colors.first).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: widget.isLoading
          ? const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: widget.textStyle ??
                      const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
    );

    if (widget.shimmerEffect && !isDisabled) {
      buttonContent = Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.0),
        highlightColor: Colors.white.withValues(alpha: 0.25),
        child: buttonContent,
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: isDisabled ? null : _onTapDown,
        onTapUp: isDisabled ? null : _onTapUp,
        onTapCancel: isDisabled ? null : _onTapCancel,
        onTap: isDisabled ? null : widget.onPressed,
        child: buttonContent,
      ),
    );
  }
}
