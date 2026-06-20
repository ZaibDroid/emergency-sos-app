import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../shared/widgets/action_list_tile.dart';
import '../../../shared/widgets/custom_button.dart';

class NonEmergencySheet extends StatelessWidget {
  const NonEmergencySheet({super.key});

  Future<void> _dialNumber(String number) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);
    try {
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not open dialer.');
    }
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return const NonEmergencySheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final helplines = [
      {'icon': Icons.local_police, 'title': 'Police Helpline', 'subtitle': 'Dial 15', 'number': '15'},
      {'icon': Icons.medical_services, 'title': 'Edhi Ambulance', 'subtitle': 'Dial 115', 'number': '115'},
      {'icon': Icons.car_crash, 'title': 'Motorway Police', 'subtitle': 'Dial 130', 'number': '130'},
    ];

    return SafeArea(
      child: Wrap(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Text(
              'Non-Emergency Contacts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...helplines.map((helpline) => ActionListTile(
            icon: helpline['icon'] as IconData,
            title: helpline['title'] as String,
            subtitle: helpline['subtitle'] as String,
            onTap: () {
              Navigator.pop(context);
              _dialNumber(helpline['number'] as String);
            },
          )),
          const SizedBox(height: 32),
          CustomButton(
            onPressed: () => _dialNumber('112'),
            icon: Icons.phone,
            label: 'Call 112 (General)',
          ),
          const SizedBox(height: 12),
          CustomButton(
            onPressed: () => _dialNumber('15'),
            icon: Icons.local_police,
            label: 'Call 15 (Police)',
            isOutlined: true,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
