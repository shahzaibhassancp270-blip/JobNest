// lib/features/home/presentation/providers/job_search_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobnest/features/home/models/job_model.dart';
import 'package:jobnest/features/home/data/job_api_service.dart';

final jobApiServiceProvider = Provider((ref) => JobApiService());

class JobSearchState {
  final List<JobModel> jobs;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final String query;
  final bool hasMore;

  JobSearchState({
    this.jobs = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.query = '',
    this.hasMore = true,
  });

  JobSearchState copyWith({
    List<JobModel>? jobs,
    bool? isLoading,
    String? error,
    int? currentPage,
    String? query,
    bool? hasMore,
  }) {
    return JobSearchState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class JobSearchNotifier extends Notifier<JobSearchState> {
  @override
  JobSearchState build() {
    return JobSearchState();
  }

  Future<void> searchJobs(String query, {bool remoteOnly = false, String employmentType = 'FULLTIME', String? location}) async {
    if (query.isEmpty) return;
    
    String finalQuery = query;
    if (location != null && location.isNotEmpty) {
      finalQuery = "$query in $location";
    }

    state = state.copyWith(isLoading: true, query: finalQuery, jobs: [], currentPage: 1, hasMore: true);
    
    try {
      final jobs = await ref.read(jobApiServiceProvider).searchJobs(
        query: finalQuery,
        page: 1,
        remoteOnly: remoteOnly,
        employmentTypes: employmentType,
      );
      state = state.copyWith(isLoading: false, jobs: jobs, hasMore: jobs.isNotEmpty);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    try {
      final newJobs = await ref.read(jobApiServiceProvider).searchJobs(
        query: state.query,
        page: nextPage,
      );
      
      if (newJobs.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          jobs: [...state.jobs, ...newJobs],
          currentPage: nextPage,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final jobSearchProvider = NotifierProvider<JobSearchNotifier, JobSearchState>(JobSearchNotifier.new);
