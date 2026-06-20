import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/location_provider.dart';

class LocationStatusCard extends StatelessWidget {
  const LocationStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return InkWell(
          onTap: locationProvider.isLocating ? null : locationProvider.refreshLocation,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color: locationProvider.hasLocationLock
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : theme.colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: locationProvider.hasLocationLock
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      locationProvider.isLocating
                          ? 'PROCESSING...'
                          : (locationProvider.hasLocationLock
                              ? 'GPS LOCKED'
                              : 'SEARCHING GPS...'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: locationProvider.hasLocationLock
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                      ),
                    ),
                    if (!locationProvider.isLocating) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.refresh,
                        size: 16.w,
                        color: locationProvider.hasLocationLock
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  locationProvider.locationStatus,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                if (locationProvider.isLocating && !locationProvider.hasLocationLock)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0.h),
                    child: const LinearProgressIndicator(),
                  )
                else if (!locationProvider.hasLocationLock)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0.h),
                    child: const LinearProgressIndicator(
                      value: null,
                    ), // Indeterminate for searching
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
