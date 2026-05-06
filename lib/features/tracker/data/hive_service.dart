// lib/features/tracker/data/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jobnest/features/tracker/models/application_model.dart';
import 'package:jobnest/features/home/models/job_model.dart';

class HiveService {
  static const String applicationsBoxName = 'applications';
  static const String savedJobsBoxName = 'savedJobs';

  Box<ApplicationModel> get applicationsBox => Hive.box<ApplicationModel>(applicationsBoxName);
  Box<SavedJobModel> get savedJobsBox => Hive.box<SavedJobModel>(savedJobsBoxName);

  // Applications CRUD
  Future<void> addApplication(ApplicationModel application) async {
    await applicationsBox.put(application.id, application);
  }

  Future<void> updateApplication(ApplicationModel application) async {
    await application.save();
  }

  Future<void> deleteApplication(String id) async {
    await applicationsBox.delete(id);
  }

  List<ApplicationModel> getAllApplications() {
    return applicationsBox.values.toList();
  }

  // Saved Jobs CRUD
  Future<void> saveJob(SavedJobModel job) async {
    await savedJobsBox.put(job.jobId, job);
  }

  Future<void> unsaveJob(String jobId) async {
    await savedJobsBox.delete(jobId);
  }

  bool isJobSaved(String jobId) {
    return savedJobsBox.containsKey(jobId);
  }

  List<SavedJobModel> getSavedJobs() {
    return savedJobsBox.values.toList();
  }
}
