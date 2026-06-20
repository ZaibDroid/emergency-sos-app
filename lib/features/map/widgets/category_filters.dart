import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/widgets/service_category_chip.dart';

class CategoryFilters extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilters({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category['type'];
          return ServiceCategoryChip(
            category: category,
            isSelected: isSelected,
            onSelected: onCategorySelected,
          );
        }).toList(),
      ),
    );
  }
}
