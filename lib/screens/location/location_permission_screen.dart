import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/decorative_background.dart';
import '../../shared/widgets/primary_auth_button.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('location_enabled', true);

        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
          await prefs.setDouble('location_lat', position.latitude);
          await prefs.setDouble('location_lng', position.longitude);
        } catch (_) {
          // Ignore location fetch timeout if position unavailable on emulator/device
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location access enabled successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
        _navigateToWelcome();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permissions are permanently denied. You can enable them in device settings.'),
              backgroundColor: AppColors.secondaryText,
            ),
          );
        }
        _navigateToWelcome();
        return;
      }

      // Permission denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission was denied. Proceeding to welcome.'),
            backgroundColor: AppColors.secondaryText,
          ),
        );
      }
      _navigateToWelcome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location request status: $e'),
            backgroundColor: AppColors.secondaryText,
          ),
        );
      }
      _navigateToWelcome();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToWelcome() {
    if (mounted) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(),

              // Standalone Location Illustration (No white card background)
              SizedBox(
                width: double.infinity,
                height: 250,
                child: Image.asset(
                  AppAssets.locationPin,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 90,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                "Find What's Near You",
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                "Allow location access to help us show relevant delivery options and improve your shopping experience.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.5,
                  fontSize: 14,
                ),
              ),

              const Spacer(),

              // Primary Action: Enable Location
              PrimaryAuthButton(
                text: 'Enable Location',
                isLoading: _isLoading,
                onPressed: _requestLocationPermission,
              ),
              const SizedBox(height: 12),

              // Secondary Action: Maybe Later
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _navigateToWelcome,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryText,
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Maybe Later',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
