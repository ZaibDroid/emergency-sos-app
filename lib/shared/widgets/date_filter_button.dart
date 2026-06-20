import 'package:flutter/material.dart';

class DateFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final DateTime? date;
  final String label;

  const DateFilterButton({
    super.key,
    required this.onPressed,
    this.date,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date == null ? label : '${date!.day}/${date!.month}/${date!.year}'),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
