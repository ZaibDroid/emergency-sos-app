import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../shared/widgets/contact_form_dialog.dart';
import 'pages/profile_setup_page.dart';
import 'pages/contacts_setup_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  void _showAddContactDialog(BuildContext context, OnboardingProvider provider) {
    if (provider.contacts.length >= 4) {
      Fluttertoast.showToast(msg: 'Maximum of 4 contacts allowed during setup.', gravity: ToastGravity.BOTTOM);
      return;
    }
    ContactFormDialog.show(
      context,
      onSave: provider.addContact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            return PageView(
              controller: provider.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: provider.setPage,
              children: [
                ProfileSetupPage(
                  nameController: provider.nameController,
                  phoneController: provider.phoneController,
                  profileImagePath: provider.profileImagePath,
                  onPickImage: provider.pickImage,
                  onNextPage: provider.nextPage,
                ),
                ContactsSetupPage(
                  contacts: provider.contacts,
                  onAddContact: () => _showAddContactDialog(context, provider),
                  onDeleteContact: provider.deleteContact,
                  onCompleteOnboarding: () => provider.completeOnboarding(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
