import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

/// Horizontal scrollable row of filter chips (e.g. All Photos, Latest, My Uploads).
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.labels,
    this.selectedIndex = 0,
    this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < labels.length - 1 ? 12 : 0),
            child: FilterChip(
              label: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              selected: selected,
              onSelected: onSelected != null ? (_) => onSelected!(i) : null,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: selected ? theme.colorScheme.primary : Colors.transparent,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          );
        }),
      ),
    );
  }
}
