// lib/features/home/data/job_api_service.dart
import 'package:dio/dio.dart';
import 'package:jobnest/core/constants/api_keys.dart';
import 'package:jobnest/features/home/models/job_model.dart';

class JobApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsearch.p.rapidapi.com',
      headers: {
        'X-RapidAPI-Key': ApiKeys.rapidApiKey,
        'X-RapidAPI-Host': ApiKeys.rapidApiHost,
      },
    ),
  );

  Future<List<JobModel>> searchJobs({
    required String query,
    int page = 1,
    List<String>? employmentTypes, // now a list for multi-select
    String datePosted = 'all',     // 'all', 'today', 'week', 'month'
    bool remoteOnly = false,
    String? country,               // 2-letter country code
  }) async {
    try {
      // Build employment types string — JSearch accepts comma-separated
      final empTypes = (employmentTypes != null && employmentTypes.isNotEmpty)
          ? employmentTypes.join(',')
          : null;

      final response = await _dio.get('/search', queryParameters: {
        'query': query,
        'page': page,
        'num_pages': 1,
        if (empTypes != null) 'employment_types': empTypes,
        'date_posted': datePosted,
        'remote_jobs_only': remoteOnly ? 'true' : 'false',
        if (country != null) 'country': country,
      });

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => JobModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      rethrow;
    }
  }
}
