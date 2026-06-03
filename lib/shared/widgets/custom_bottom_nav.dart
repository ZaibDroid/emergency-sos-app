import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.emergency,
            label: 'Emergency',
            isEmergency: true,
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.group,
            label: 'Contacts',
          ),
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.notifications,
            label: 'Alerts',
          ),
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    bool isEmergency = false,
  }) {
    final isSelected = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    Color itemColor;
    if (isSelected) {
      itemColor = isEmergency ? colorScheme.primary : colorScheme.secondary;
    } else {
      itemColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    }

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: isEmergency && isSelected
            ? BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: itemColor, size: 24.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: itemColor, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}
