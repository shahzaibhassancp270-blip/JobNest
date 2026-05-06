// lib/features/tracker/presentation/providers/applications_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobnest/features/tracker/models/application_model.dart';
import 'package:jobnest/features/home/models/job_model.dart';
import 'package:jobnest/features/tracker/data/hive_service.dart';
import 'package:jobnest/features/tracker/data/notification_service.dart';
import 'package:uuid/uuid.dart';

final hiveServiceProvider = Provider((ref) => HiveService());
final notificationServiceProvider = Provider((ref) => NotificationService());

class ApplicationsNotifier extends Notifier<List<ApplicationModel>> {
  @override
  List<ApplicationModel> build() {
    return ref.read(hiveServiceProvider).getAllApplications();
  }

  Future<void> addApplicationFromJob(JobModel job, String status) async {
    final application = ApplicationModel(
      id: const Uuid().v4(),
      jobTitle: job.jobTitle ?? 'Unknown Position',
      companyName: job.employerName ?? 'Unknown Company',
      companyLogo: job.employerLogo,
      jobUrl: job.jobApplyLink ?? '',
      status: status,
      notes: '',
      resumeLink: '',
      appliedDate: DateTime.now(),
    );
    await ref.read(hiveServiceProvider).addApplication(application);
    state = [...state, application];
  }

  Future<void> updateApplication(ApplicationModel application) async {
    await ref.read(hiveServiceProvider).updateApplication(application);
    state = [
      for (final app in state)
        if (app.id == application.id) application else app
    ];

    // Handle reminders
    if (application.status == 'Interview' && application.interviewDate != null) {
      await ref.read(notificationServiceProvider).scheduleInterviewReminder(
        id: application.id.hashCode,
        title: application.jobTitle,
        body: "Interview with ${application.companyName}",
        scheduledDate: application.interviewDate!,
      );
    } else {
      await ref.read(notificationServiceProvider).cancelReminder(application.id.hashCode);
    }
  }

  Future<void> deleteApplication(String id) async {
    await ref.read(hiveServiceProvider).deleteApplication(id);
    await ref.read(notificationServiceProvider).cancelReminder(id.hashCode);
    state = state.where((app) => app.id != id).toList();
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final app = state.firstWhere((element) => element.id == id);
    final updatedApp = app.copyWith(status: newStatus);
    await updateApplication(updatedApp);
  }
}

final applicationsProvider = NotifierProvider<ApplicationsNotifier, List<ApplicationModel>>(ApplicationsNotifier.new);

// Saved Jobs Provider
class SavedJobsNotifier extends Notifier<List<SavedJobModel>> {
  @override
  List<SavedJobModel> build() {
    return ref.read(hiveServiceProvider).getSavedJobs();
  }

  Future<void> toggleSave(JobModel job) async {
    final hive = ref.read(hiveServiceProvider);
    if (hive.isJobSaved(job.jobId!)) {
      await hive.unsaveJob(job.jobId!);
    } else {
      await hive.saveJob(job.toSavedJobModel());
    }
    state = hive.getSavedJobs();
  }

  bool isSaved(String jobId) => ref.read(hiveServiceProvider).isJobSaved(jobId);
}

final savedJobsProvider = NotifierProvider<SavedJobsNotifier, List<SavedJobModel>>(SavedJobsNotifier.new);
