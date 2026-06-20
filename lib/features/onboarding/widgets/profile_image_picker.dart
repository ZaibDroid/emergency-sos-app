import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const ProfileImagePicker({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 85.r,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
            child: imagePath == null
                ? Icon(Icons.person, size: 85.w, color: theme.colorScheme.primary)
                : null,
          ),
          CircleAvatar(
            radius: 26.r,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.camera_alt, size: 28.w, color: theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}
