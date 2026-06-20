import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onEditProfile;

  const ProfileHeader({super.key, required this.onEditProfile});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null && context.mounted) {
        context.read<UserProvider>().updateProfileImage(image.path);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to pick image: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _pickImage(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showImagePickerOptions(context),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      backgroundImage: provider.userProfileImagePath != null
                          ? FileImage(File(provider.userProfileImagePath!))
                          : null,
                      child: provider.userProfileImagePath == null
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: theme.colorScheme.onSecondaryContainer,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                provider.userName.isNotEmpty ? provider.userName : 'User Name',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                provider.userPhone.isNotEmpty ? provider.userPhone : 'Not set',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              CustomButton(
                onPressed: onEditProfile,
                icon: Icons.edit,
                label: 'Edit Profile',
                isOutlined: true,
                isFullWidth: false,
              ),
            ],
          ),
        );
      },
    );
  }
}
