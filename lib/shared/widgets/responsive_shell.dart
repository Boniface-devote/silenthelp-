import 'package:flutter/material.dart';

class ResponsiveShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveShell({
    Key? key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final resolvedMaxWidth = availableWidth < maxWidth ? availableWidth : maxWidth;
        final resolvedPadding = availableWidth > maxWidth
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
            : padding;

        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
              child: Padding(
                padding: resolvedPadding,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
