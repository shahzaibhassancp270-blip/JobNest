// lib/features/saved/presentation/screens/saved_jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/features/tracker/presentation/providers/applications_provider.dart';
import 'package:jobnest/features/home/models/job_model.dart';
import 'package:jobnest/core/constants/app_colors.dart';

class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedJobs = ref.watch(savedJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Saved Jobs',
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
      body: savedJobs.isEmpty
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
                    child: const Icon(Icons.bookmark_outline_rounded,
                        size: 64, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Saved Jobs',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jobs you bookmark will appear here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedJobs.length,
              itemBuilder: (context, index) {
                final job = savedJobs[index];
                return GestureDetector(
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
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Logo
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.08),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: job.companyLogo != null
                              ? Image.network(
                                  job.companyLogo!,
                                  fit: BoxFit.contain,
                                  cacheWidth: 104,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.business_rounded,
                                      color: AppColors.primary,
                                      size: 24),
                                )
                              : const Icon(Icons.business_rounded,
                                  color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.companyName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                job.jobTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_rounded,
                              color: AppColors.primary),
                          onPressed: () {
                            final tempJob = JobModel(jobId: job.jobId);
                            ref
                                .read(savedJobsProvider.notifier)
                                .toggleSave(tempJob);
                          },
                        ),
                      ],
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
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/tracker');
              break;
            case 2:
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
              icon: Icon(Icons.bookmark_rounded), label: 'Saved'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
        ],
      ),
    );
  }
}
