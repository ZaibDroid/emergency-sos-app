import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/contact_model.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/contact_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  final List<ContactModel> _contacts = [];
  int _currentPage = 0;
  String? _profileImagePath;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (_profileImagePath == null) {
        Fluttertoast.showToast(msg: 'Please select a profile picture', gravity: ToastGravity.BOTTOM);
        return;
      }
      if (_nameController.text.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'Please enter your full name', gravity: ToastGravity.BOTTOM);
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'Please enter your phone number', gravity: ToastGravity.BOTTOM);
        return;
      }
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _completeOnboarding() async {
    if (_contacts.isEmpty) {
      Fluttertoast.showToast(msg: 'Please add at least 1 emergency contact', gravity: ToastGravity.BOTTOM);
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    await userProvider.saveUserProfile(
      name: name,
      phone: phone,
      imagePath: _profileImagePath,
    );
    await userProvider.setContacts(_contacts);
    await userProvider.completeOnboarding();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _showAddContactDialog() {
    if (_contacts.length >= 4) {
      Fluttertoast.showToast(msg: 'Maximum of 4 contacts allowed during setup.', gravity: ToastGravity.BOTTOM);
      return;
    }

    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                labelText: 'Name',
                prefixIcon: Icons.person,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: phoneController,
                labelText: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || phone.isEmpty) {
                  Fluttertoast.showToast(msg: 'Please enter both name and phone number');
                  return;
                }

                setState(() {
                  _contacts.add(
                    ContactModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      phoneNumber: phone,
                    ),
                  );
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteContact(String id) {
    setState(() {
      _contacts.removeWhere((c) => c.id == id);
    });
  }

  Widget _buildProfilePage(ThemeData theme) {
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
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 85.r,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                    child: _profileImagePath == null
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
            ),
          ),
          SizedBox(height: 32.h),
          CustomTextField(
            controller: _nameController,
            labelText: 'Your Full Name',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _phoneController,
            labelText: 'Your Phone Number',
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 32.h),
          CustomButton(
            onPressed: _nextPage,
            label: 'Next: Add Contacts',
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildContactsPage(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(24.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 48.h),
          Text('Emergency Contacts', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text(
            'Add up to 4 trusted people who will receive your SOS alerts.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: _contacts.isEmpty
                ? Center(
                    child: Text(
                      'No contacts added yet.\nPress "Add Contact" to add a contact.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ContactCard(
                        contact: contact,
                        onDelete: () => _deleteContact(contact.id),
                      );
                    },
                  ),
          ),
          if (_contacts.length < 4)
            CustomButton(
              onPressed: _showAddContactDialog,
              icon: Icons.person_add,
              label: 'Add Contact',
              isOutlined: true,
            ),
          SizedBox(height: 16.h),
          CustomButton(
            onPressed: _completeOnboarding,
            label: 'Finish Setup',
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe to force using buttons
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildProfilePage(theme),
            _buildContactsPage(theme),
          ],
        ),
      ),
    );
  }
}
