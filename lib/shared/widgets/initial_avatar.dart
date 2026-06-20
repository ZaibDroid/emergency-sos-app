import 'package:flutter/material.dart';

class InitialAvatar extends StatelessWidget {
  final String name;
  final Color? backgroundColor;
  final Color? textColor;
  final double? radius;

  const InitialAvatar({
    super.key,
    required this.name,
    this.backgroundColor,
    this.textColor,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: textColor ?? theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
