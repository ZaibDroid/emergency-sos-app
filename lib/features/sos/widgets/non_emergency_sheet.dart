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
      {'icon': Icons.local_police, 'title': 'Police', 'subtitle': 'Dial 15', 'number': '15'},
      {'icon': Icons.medical_services, 'title': 'Edhi Ambulance', 'subtitle': 'Dial 115', 'number': '115'},
      {'icon': Icons.medical_services, 'title': 'Chhipa Ambulance', 'subtitle': 'Dial 1020', 'number': '1020'},
      {'icon': Icons.car_crash, 'title': 'Motorway Police', 'subtitle': 'Dial 130', 'number': '130'},
      {'icon': Icons.medical_services, 'title': '1122 Ambulance', 'subtitle': 'Dial 1122', 'number': '1122'},
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
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
