// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobnest/features/profile/presentation/providers/theme_provider.dart';
import 'package:jobnest/core/constants/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'User Name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'user@example.com',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            _buildProfileTile(
              context,
              Icons.notifications_outlined,
              'Interview Reminders',
              onTap: () => context.push('/reminders'),
            ),
            _buildProfileTile(
              context,
              Icons.dark_mode_outlined,
              'Dark Mode',
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
              ),
            ),
            _buildProfileTile(
              context,
              Icons.help_outline,
              'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 40),
            ListTile(
              onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.red.withOpacity(0.05),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context, IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
    );
  }
}
