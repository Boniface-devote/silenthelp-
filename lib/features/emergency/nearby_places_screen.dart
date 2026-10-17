import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({super.key});

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  bool _isOpeningMap = false;

  Future<void> _openMapSearch(String category, {bool needsSafetyNotice = false}) async {
    if (_isOpeningMap) return;

    if (needsSafetyNotice) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Check listings before visiting'),
          content: const Text(
            'Map search results for safe spaces are not verified by SilentHelp. '
            'Check that a place is open and safe to visit before travelling.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Continue to map'),
            ),
          ],
        ),
      );
      if (accepted != true) return;
    }

    setState(() => _isOpeningMap = true);
    try {
      var location = await LocationService.getCachedLocation();
      if (location == null && await LocationService.ensureLocationPermission()) {
        location = await LocationService.getFullLocation();
      }

      final locationQuery = location == null
          ? 'near me'
          : 'near ${location.latitude.toStringAsFixed(5)}, '
              '${location.longitude.toStringAsFixed(5)}';
      final uri = Uri.https(
        'www.google.com',
        '/maps/search/',
        {
          'api': '1',
          'query': '$category $locationQuery',
        },
      );
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the map app.')),
        );
      }
    } catch (_) {
      final uri = Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '$category near me',
      });
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the map app.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpeningMap = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Nearby Support', style: AppTextStyles.heading2),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Text(
            'Searches open Google Maps and include your recent coordinates '
            'when available. If needed, SilentHelp requests location access '
            'when you start a search.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: 20.h),
          _PlaceSearchCard(
            icon: Icons.shield_outlined,
            color: AppColors.purple,
            title: 'Safe spaces and women’s support',
            description: 'Search for shelters and local support services.',
            isLoading: _isOpeningMap,
            onTap: () => _openMapSearch(
              'women shelter or women support service',
              needsSafetyNotice: true,
            ),
          ),
          _PlaceSearchCard(
            icon: Icons.local_hospital_outlined,
            color: AppColors.red,
            title: 'Hospitals',
            description: 'Find hospitals near your current location.',
            isLoading: _isOpeningMap,
            onTap: () => _openMapSearch('hospital'),
          ),
          _PlaceSearchCard(
            icon: Icons.medical_services_outlined,
            color: AppColors.blue,
            title: 'Clinics',
            description: 'Find clinics and health centres nearby.',
            isLoading: _isOpeningMap,
            onTap: () => _openMapSearch('clinic or health centre'),
          ),
          _PlaceSearchCard(
            icon: Icons.local_police_outlined,
            color: AppColors.yellow,
            title: 'Police stations',
            description: 'Find police stations near your current location.',
            isLoading: _isOpeningMap,
            onTap: () => _openMapSearch('police station'),
          ),
          SizedBox(height: 12.h),
          Text(
            'Map results require an internet connection and may be incomplete. '
            'Safe-space listings are third-party search results, not verified '
            'referrals. Use your Trusted Circle or local emergency services if '
            'you need immediate help.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _PlaceSearchCard extends StatelessWidget {
  const _PlaceSearchCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.w),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.18),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTextStyles.labelMedium),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(description, style: AppTextStyles.caption),
        ),
        trailing: isLoading
            ? SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.map_outlined, color: AppColors.teal, size: 24.sp),
        onTap: isLoading ? null : onTap,
      ),
    );
  }
}
