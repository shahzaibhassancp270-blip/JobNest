// lib/features/home/presentation/screens/job_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobnest/features/home/models/job_model.dart';
import 'package:jobnest/core/constants/app_colors.dart';
import 'package:jobnest/features/tracker/presentation/providers/applications_provider.dart';
import 'package:jobnest/core/utils/snackbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailScreen extends ConsumerWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(savedJobsProvider.notifier).isSaved(job.jobId ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Detail'),
        actions: [
          IconButton(
            icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? AppColors.primary : null),
            onPressed: () => ref.read(savedJobsProvider.notifier).toggleSave(job),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: job.employerLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(job.employerLogo!, fit: BoxFit.contain),
                        )
                      : const Icon(Icons.business, size: 40, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobTitle ?? 'No Title',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        job.employerName ?? 'Unknown Company',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCard(context, Icons.location_on_outlined, 'Location', job.jobCity ?? 'Remote'),
                _buildInfoCard(context, Icons.work_outline, 'Type', job.jobEmploymentType ?? 'Full Time'),
                _buildInfoCard(context, Icons.currency_bitcoin, 'Salary', 'Competitive'),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Job Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              job.jobDescription ?? 'No description provided.',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(applicationsProvider.notifier).addApplicationFromJob(job, 'Saved');
                  if (context.mounted) SnackBarHelper.showSuccess(context, 'Added to Tracker');
                },
                child: const Text('Track Job'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _launchUrl(job.jobApplyLink ?? ''),
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
