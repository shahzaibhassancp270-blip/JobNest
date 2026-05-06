// lib/routing/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobnest/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobnest/features/auth/presentation/screens/login_screen.dart';
import 'package:jobnest/features/auth/presentation/screens/register_screen.dart';
import 'package:jobnest/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:jobnest/features/auth/presentation/screens/splash_screen.dart';
import 'package:jobnest/features/home/presentation/screens/home_screen.dart';
import 'package:jobnest/features/home/presentation/screens/job_detail_screen.dart';
import 'package:jobnest/features/tracker/presentation/screens/kanban_screen.dart';
import 'package:jobnest/features/tracker/presentation/screens/application_detail_screen.dart';
import 'package:jobnest/features/saved/presentation/screens/saved_jobs_screen.dart';
import 'package:jobnest/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:jobnest/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:jobnest/features/profile/presentation/screens/profile_screen.dart';
import 'package:jobnest/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:jobnest/features/jobs/presentation/screens/post_job_screen.dart';
import 'package:jobnest/features/home/models/job_model.dart';
import 'package:jobnest/features/tracker/models/application_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final path = state.matchedLocation;
      final isAuthPath = path.startsWith('/auth');
      final isSplash = path == '/splash';
      final isOnboarding = path == '/onboarding';

      // Not logged in → force to login
      if (!isLoggedIn && !isAuthPath && !isSplash && !isOnboarding) {
        return '/auth/login';
      }
      // Logged in and stuck on an auth screen (e.g. after Google sign-in)
      // → send through splash so onboarding check fires
      if (isLoggedIn && isAuthPath) return '/splash';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'job-detail',
            builder: (context, state) => JobDetailScreen(job: state.extra as JobModel),
          ),
        ],
      ),
      GoRoute(
        path: '/tracker',
        builder: (context, state) => const KanbanScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) =>
                ApplicationDetailScreen(application: state.extra as ApplicationModel),
          ),
        ],
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const SavedJobsScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/post-job',
        builder: (context, state) => const PostJobScreen(),
      ),
    ],
  );
});
