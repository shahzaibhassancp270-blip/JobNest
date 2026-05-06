// lib/features/auth/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/core/constants/app_colors.dart';
import 'package:jobnest/core/constants/app_strings.dart';
import 'package:jobnest/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobnest/features/onboarding/data/preferences_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Max 4 second timeout
    Future.delayed(const Duration(seconds: 4), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted || _navigated) return;
    _navigated = true;

    final user = ref.read(userProvider);
    if (user == null) {
      context.go('/auth/login');
      return;
    }

    // Check if user has done onboarding
    final prefsService = PreferencesService();
    final onboardingDone = await prefsService.isOnboardingDone();
    if (!mounted) return;

    if (onboardingDone) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Navigate as soon as auth state resolves
    ref.listen(authStateProvider, (previous, next) {
      if (next.hasValue) _navigate();
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.work_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
