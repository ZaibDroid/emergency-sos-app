import 'package:url_launcher/url_launcher.dart';
import '../../models/contact_model.dart';

class SmsService {
  Future<void> sendSosSms({
    required List<ContactModel> contacts,
    required String customMessage,
    required double latitude,
    required double longitude,
  }) async {
    if (contacts.isEmpty) {
      throw Exception('No trusted contacts found! Please add them in the Contacts tab.');
    }

    final String mapsLink = 'https://maps.google.com/?q=$latitude,$longitude';
    final String fullMessage = '$customMessage\n$mapsLink';

    // Clean phone numbers and join
    final String phoneNumbers = contacts
        .map((c) => c.phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''))
        .join(',');

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumbers,
      queryParameters: <String, String>{'body': fullMessage},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw Exception('Could not launch SMS app on this device.');
    }
  }
}
