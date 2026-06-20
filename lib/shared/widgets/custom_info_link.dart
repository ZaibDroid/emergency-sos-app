import 'package:flutter/material.dart';

class CustomInfoLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomInfoLink({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
