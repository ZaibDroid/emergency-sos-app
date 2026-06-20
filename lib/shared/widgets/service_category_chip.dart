import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServiceCategoryChip extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  const ServiceCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(right: 8.0.w),
      child: FilterChip(
        selected: isSelected,
        label: Text(category['label']),
        avatar: Icon(
          category['icon'],
          size: 18.w,
          color: isSelected
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
        onSelected: (bool selected) {
          if (selected) {
            onSelected(category['type']);
          }
        },
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.secondaryContainer,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
