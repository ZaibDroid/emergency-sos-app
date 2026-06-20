import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';

class UserProfileApplet extends StatelessWidget {
  final VoidCallback onTap;

  const UserProfileApplet({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        String? imagePath = userProvider.userProfileImagePath;
        String userName = userProvider.userName.isNotEmpty ? userProvider.userName : 'User';
        
        // Extract first name if it's too long
        if (userName.contains(' ')) {
          userName = userName.split(' ')[0];
        }

        return GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi, $userName',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 8.w),
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
                  child: imagePath == null ? Icon(Icons.person, size: 20.w) : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
