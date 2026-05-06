// lib/features/tracker/presentation/screens/kanban_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/features/tracker/presentation/providers/applications_provider.dart';
import 'package:jobnest/features/tracker/presentation/widgets/kanban_column.dart';
import 'package:jobnest/core/constants/app_colors.dart';

class KanbanScreen extends ConsumerWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsProvider);
    final statuses = ['Saved', 'Applied', 'Interview', 'Offer', 'Rejected'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Application Tracker',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: applications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.view_kanban_outlined,
                        size: 64, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Applications Yet',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save or apply to jobs to start tracking them here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: statuses.map((status) {
                  final filteredApps =
                      applications.where((app) => app.status == status).toList();
                  return KanbanColumn(
                    title: status,
                    applications: filteredApps,
                    onTap: (app) => context.push('/tracker/detail', extra: app),
                  );
                }).toList(),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              break;
            case 2:
              context.go('/saved');
              break;
            case 3:
              context.go('/analytics');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_kanban_outlined), label: 'Tracker'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline_rounded), label: 'Saved'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
        ],
      ),
    );
  }
}
