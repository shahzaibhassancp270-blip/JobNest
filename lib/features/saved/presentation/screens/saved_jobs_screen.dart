// lib/features/saved/presentation/screens/saved_jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/features/tracker/presentation/providers/applications_provider.dart';
import 'package:jobnest/features/home/models/job_model.dart';

class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedJobs = ref.watch(savedJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: savedJobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No saved jobs yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedJobs.length,
              itemBuilder: (context, index) {
                final job = savedJobs[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    onTap: () {
                      final fullJob = JobModel(
                        jobId: job.jobId,
                        jobTitle: job.jobTitle,
                        employerName: job.companyName,
                        employerLogo: job.companyLogo,
                        jobCity: job.location.split(',').first.trim(),
                        jobApplyLink: job.applyLink,
                        jobEmploymentType: job.employmentType,
                      );
                      context.push('/job-detail', extra: fullJob);
                    },
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: job.companyLogo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(job.companyLogo!, fit: BoxFit.contain),
                            )
                          : const Icon(Icons.business),
                    ),
                    title: Text(job.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(job.companyName),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark, color: Colors.blue),
                      onPressed: () {
                        final tempJob = JobModel(jobId: job.jobId);
                        ref.read(savedJobsProvider.notifier).toggleSave(tempJob);
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0: context.push('/'); break;
            case 1: context.push('/tracker'); break;
            case 2: break;
            case 3: context.push('/analytics'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.view_kanban_outlined), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
        ],
      ),
    );
  }
}
