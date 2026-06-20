import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/profile_image_picker.dart';

class ProfileSetupPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String? profileImagePath;
  final VoidCallback onPickImage;
  final VoidCallback onNextPage;

  const ProfileSetupPage({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.profileImagePath,
    required this.onPickImage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 40.h),
          Text('Your Profile', style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          Text(
            'Set up your personal details before adding emergency contacts.',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          Center(
            child: ProfileImagePicker(
              imagePath: profileImagePath,
              onTap: onPickImage,
            ),
          ),
          SizedBox(height: 32.h),
          CustomTextField(
            controller: nameController,
            labelText: 'Your Full Name',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: phoneController,
            labelText: 'Your Phone Number',
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 32.h),
          CustomButton(
            onPressed: onNextPage,
            label: 'Next: Add Contacts',
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
