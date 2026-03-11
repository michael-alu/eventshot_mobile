import 'package:flutter/material.dart';

/// Simple 3-column grid of image placeholders (for shared gallery).
class GalleryGrid extends StatelessWidget {
  const GalleryGrid({
    super.key,
    required this.itemCount,
    this.itemBuilder,
    this.onItemTap,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index)? itemBuilder;
  final void Function(int index)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final child = itemBuilder != null
            ? itemBuilder!(context, index)
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              );
        if (onItemTap != null) {
          return GestureDetector(
            onTap: () => onItemTap!(index),
            child: child,
          );
        }
        return child;
      },
    );
  }
}
