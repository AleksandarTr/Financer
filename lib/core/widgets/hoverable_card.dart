import 'package:flutter/material.dart';

class HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets margin;
  final Duration animationDuration;

  const HoverableCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.borderWidth = 2,
    this.borderRadius = 8,
    this.margin = const EdgeInsets.all(2),
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: RepaintBoundary( // FIXES: _addToSceneWithRetainedRendering
            child: AnimatedContainer(
              duration: widget.animationDuration,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                color: _isHovered
                    ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                    : Colors.transparent,
                border: widget.borderColor != null
                    ? Border.all(color: widget.borderColor!, width: widget.borderWidth)
                    : null,
              ),
              child: IgnorePointer( // FIXES: RenderBox.hitTest bottleneck
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
