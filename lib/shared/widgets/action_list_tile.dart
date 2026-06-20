import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? contentPadding;

  const ActionListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 24.w,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding,
    );
  }
}
