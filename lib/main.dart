// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jobnest/firebase_options.dart';
import 'package:jobnest/routing/app_router.dart';
import 'package:jobnest/core/theme/app_theme.dart';
import 'package:jobnest/features/profile/presentation/providers/theme_provider.dart';
import 'package:jobnest/features/tracker/data/notification_service.dart';
import 'package:jobnest/features/tracker/models/application_model.dart';
import 'package:jobnest/features/home/models/job_model.dart';
import 'package:jobnest/features/tracker/models/reminder_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(ApplicationModelAdapter());
  Hive.registerAdapter(SavedJobModelAdapter());
  Hive.registerAdapter(ReminderModelAdapter());
  
  // Open Boxes
  await Hive.openBox<ApplicationModel>('applications');
  await Hive.openBox<SavedJobModel>('savedJobs');
  await Hive.openBox<ReminderModel>('reminders');

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    const ProviderScope(
      child: JobNestApp(),
    ),
  );
}

class JobNestApp extends ConsumerWidget {
  const JobNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'JobNest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
