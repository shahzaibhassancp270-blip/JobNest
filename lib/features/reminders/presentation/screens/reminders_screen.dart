// lib/features/reminders/presentation/screens/reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jobnest/features/tracker/presentation/providers/applications_provider.dart';
import 'package:jobnest/core/constants/app_colors.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsProvider);
    final interviewApps = applications.where((app) => app.interviewDate != null).toList();
    
    interviewApps.sort((a, b) => a.interviewDate!.compareTo(b.interviewDate!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: interviewApps.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No upcoming interviews', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: interviewApps.length,
              itemBuilder: (context, index) {
                final app = interviewApps[index];
                final isPast = app.interviewDate!.isBefore(DateTime.now());

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isPast ? Colors.grey : AppColors.primary).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: isPast ? Colors.grey : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.jobTitle,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                app.companyName,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, MMM dd • hh:mm a').format(app.interviewDate!),
                                style: TextStyle(
                                  color: isPast ? Colors.red[300] : AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isPast)
                          IconButton(
                            icon: const Icon(Icons.notifications_off_outlined, color: Colors.grey),
                            onPressed: () async {
                              final updatedApp = app.copyWith(interviewDate: null);
                              await ref.read(applicationsProvider.notifier).updateApplication(updatedApp);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
