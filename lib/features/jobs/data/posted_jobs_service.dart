// lib/features/jobs/data/posted_jobs_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobnest/features/jobs/models/posted_job_model.dart';

class PostedJobsService {
  final _db = FirebaseFirestore.instance;
  static const _collection = 'posted_jobs';

  Future<void> postJob(PostedJobModel job) async {
    await _db.collection(_collection).doc(job.id).set(job.toMap());
  }

  Future<List<PostedJobModel>> getJobsByLocation(String city) async {
    try {
      final query = await _db
          .collection(_collection)
          .where('location', isGreaterThanOrEqualTo: city)
          .where('location', isLessThanOrEqualTo: '$city\uf8ff')
          .orderBy('location')
          .orderBy('postedAt', descending: true)
          .limit(20)
          .get();

      return query.docs.map((doc) => PostedJobModel.fromMap(doc.data())).toList();
    } catch (_) {
      // Fallback: get all recent jobs
      return getAllRecentJobs();
    }
  }

  Future<List<PostedJobModel>> getAllRecentJobs() async {
    final query = await _db
        .collection(_collection)
        .orderBy('postedAt', descending: true)
        .limit(20)
        .get();
    return query.docs.map((doc) => PostedJobModel.fromMap(doc.data())).toList();
  }

  Stream<List<PostedJobModel>> streamJobsByLocation(String city) {
    return _db
        .collection(_collection)
        .orderBy('postedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => PostedJobModel.fromMap(doc.data())).toList());
  }
}
