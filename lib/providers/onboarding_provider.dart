import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/contact_model.dart';
import '../core/services/storage_service.dart';
import '../core/utils/input_validator.dart';
import 'user_provider.dart';

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final List<ContactModel> _contacts = [];
  List<ContactModel> get contacts => _contacts;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  String? _profileImagePath;
  String? get profileImagePath => _profileImagePath;

  @override
  void dispose() {
    pageController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void setPage(int index) {
    _currentPage = index;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _profileImagePath = pickedFile.path;
      notifyListeners();
    }
  }

  void addContact(ContactModel contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void deleteContact(String id) {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage == 0) {
      if (_profileImagePath == null) {
        Fluttertoast.showToast(msg: 'Please select a profile picture', gravity: ToastGravity.BOTTOM);
        return;
      }
      if (!InputValidator.isValidName(nameController.text.trim())) {
        Fluttertoast.showToast(msg: 'Please enter a valid full name', gravity: ToastGravity.BOTTOM);
        return;
      }
      if (!InputValidator.isValidPhone(phoneController.text.trim())) {
        Fluttertoast.showToast(msg: 'Please enter a valid phone number', gravity: ToastGravity.BOTTOM);
        return;
      }
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> completeOnboarding(BuildContext context) async {
    if (_contacts.isEmpty) {
      Fluttertoast.showToast(msg: 'Please add at least 1 emergency contact', gravity: ToastGravity.BOTTOM);
      return;
    }

    final name = InputValidator.sanitizeText(nameController.text);
    final phone = InputValidator.sanitizeText(phoneController.text);
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    await userProvider.saveUserProfile(
      name: name,
      phone: phone,
      imagePath: _profileImagePath,
    );
    await userProvider.setContacts(_contacts);
    await StorageService().completeOnboarding();

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
  }
}
