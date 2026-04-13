import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class BottomNavScaffold extends StatefulWidget {
  final Widget child;

  const BottomNavScaffold({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
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
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.warning, size: 24.sp),
            label: 'Emergency',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none, size: 24.sp),
            selectedIcon: Icon(Icons.mic, size: 24.sp),
            label: 'Talk',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.message, size: 24.sp),
            label: 'Phrases',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.credit_card, size: 24.sp),
            label: 'Card',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    if (location == AppConstants.routeHome) return 0;
    if (location == AppConstants.routeEmergency) return 1;
    if (location == AppConstants.routeTalk) return 2;
    if (location == AppConstants.routePhrases) return 3;
    if (location == AppConstants.routeIdCard) return 4;
    
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
        context.go(AppConstants.routePhrases);
        break;
      case 4:
        context.go(AppConstants.routeIdCard);
        break;
    }
  }
}
