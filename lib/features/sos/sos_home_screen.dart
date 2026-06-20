import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/sos_provider.dart';
import '../../../providers/location_provider.dart';
import '../../shared/widgets/sos_button.dart';
import '../../shared/widgets/quick_action_button.dart';
import 'widgets/location_status_card.dart';
import 'widgets/non_emergency_sheet.dart';

class SosHomeScreen extends StatelessWidget {
  const SosHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer2<SosProvider, LocationProvider>(
              builder: (context, sosProvider, locationProvider, child) {
                return SosButton(
                  onTriggered: sosProvider.isSending 
                      ? () {} 
                      : () => sosProvider.triggerSos(currentPosition: locationProvider.currentPosition),
                );
              },
            ),
            SizedBox(height: 40.h),
            
            // Reusable Location Status Component
            const LocationStatusCard(),
            
            SizedBox(height: 24.h),

            // Quick Secondary Actions
            Row(
              children: [
                QuickActionButton(
                  onPressed: () => NonEmergencySheet.show(context),
                  icon: Icons.phone,
                  label: 'Helplines',
                ),
                SizedBox(width: 16.w),
                QuickActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/nearby');
                  },
                  icon: Icons.local_hospital,
                  label: 'Nearby Services',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
