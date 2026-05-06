// lib/features/tracker/presentation/screens/kanban_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/features/tracker/presentation/providers/applications_provider.dart';
import 'package:jobnest/features/tracker/presentation/widgets/kanban_column.dart';

class KanbanScreen extends ConsumerWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsProvider);
    final statuses = ['Saved', 'Applied', 'Interview', 'Offer', 'Rejected'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: statuses.map((status) {
            final filteredApps = applications.where((app) => app.status == status).toList();
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
            case 0: context.go('/'); break;
            case 1: break;
            case 2: context.go('/saved'); break;
            case 3: context.go('/analytics'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.view_kanban), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
        ],
      ),
    );
  }
}
