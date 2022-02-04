import 'package:flutter/material.dart';

/// Decorates its [child] with a small circular overlay.
class DotDecoration extends StatelessWidget {
  const DotDecoration({
    Key? key,
    required this.show,
    this.color,
    this.size = 10,
    this.padding = const EdgeInsets.all(12),
    this.alignment = AlignmentDirectional.topEnd,
    this.child,
  }) : super(key: key);

  final bool show;

  final Color? color;

  final double size;

  final EdgeInsets padding;

  final AlignmentGeometry alignment;

  final Widget? child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          if (child != null) child!,
          if (show)
            Positioned.fill(
              child: Container(
                padding: padding,
                alignment: alignment,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color ??
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
              ),
            ),
        ],
      );
}
