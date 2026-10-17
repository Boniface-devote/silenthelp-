import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import 'responsive_shell.dart';

class BottomNavScaffold extends StatefulWidget {
  final Widget child;

  const BottomNavScaffold({Key? key, required this.child}) : super(key: key);

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveShell(child: widget.child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) {
          _navigateToIndex(context, index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 80.h,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.home, size: 24.sp),
            label: 'nav_home'.tr(),
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.warning, size: 24.sp),
            label: 'nav_emergency'.tr(),
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none, size: 24.sp),
            selectedIcon: Icon(Icons.mic, size: 24.sp),
            label: 'nav_talk'.tr(),
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.map, size: 24.sp),
            label: 'nav_places'.tr(),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.settings, size: 24.sp),
            label: 'nav_settings'.tr(),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location == AppConstants.routeHome) return 0;
    if (location == AppConstants.routeEmergency ||
        location == AppConstants.routeTrustedCircle)
      return 1;
    if (location == AppConstants.routeTalk) return 2;
    if (location == AppConstants.routeNearbyPlaces) return 3;
    if (location == AppConstants.routeSettings ||
        location == AppConstants.routeProfile)
      return 4;

    return 0;
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppConstants.routeHome);
        break;
      case 1:
        context.go(AppConstants.routeEmergency);
        break;
      case 2:
        context.go(AppConstants.routeTalk);
        break;
      case 3:
        context.go(AppConstants.routeNearbyPlaces);
        break;
      case 4:
        context.go(AppConstants.routeSettings);
        break;
    }
  }
}
