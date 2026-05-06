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
  final List<String> selectedEmploymentTypes;
  final String datePosted;
  final bool remoteOnly;
  final String? country; // Added country code

  JobSearchState({
    this.jobs = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.query = '',
    this.hasMore = true,
    this.selectedEmploymentTypes = const [],
    this.datePosted = 'all',
    this.remoteOnly = false,
    this.country,
  });

  JobSearchState copyWith({
    List<JobModel>? jobs,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? currentPage,
    String? query,
    bool? hasMore,
    List<String>? selectedEmploymentTypes,
    String? datePosted,
    bool? remoteOnly,
    String? country,
  }) {
    return JobSearchState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      selectedEmploymentTypes: selectedEmploymentTypes ?? this.selectedEmploymentTypes,
      datePosted: datePosted ?? this.datePosted,
      remoteOnly: remoteOnly ?? this.remoteOnly,
      country: country ?? this.country,
    );
  }
}

class JobSearchNotifier extends Notifier<JobSearchState> {
  @override
  JobSearchState build() => JobSearchState();

  Future<void> searchJobs(
    String query, {
    bool? remoteOnly,
    List<String>? employmentTypes,
    String? location,
    String? country,
    String? datePosted,
  }) async {
    if (query.isEmpty) return;

    // Build final query with location if provided
    final finalQuery = (location != null && location.isNotEmpty)
        ? '$query in $location'
        : query;

    final empTypes = employmentTypes ?? state.selectedEmploymentTypes;
    final remote = remoteOnly ?? state.remoteOnly;
    final date = datePosted ?? state.datePosted;

    state = state.copyWith(
      isLoading: true,
      query: finalQuery,
      jobs: [],
      currentPage: 1,
      hasMore: true,
      clearError: true,
      selectedEmploymentTypes: empTypes,
      remoteOnly: remote,
      datePosted: date,
      country: country,
    );

    try {
      final jobs = await ref.read(jobApiServiceProvider).searchJobs(
            query: finalQuery,
            page: 1,
            employmentTypes: empTypes.isEmpty ? null : empTypes,
            remoteOnly: remote,
            datePosted: date,
            country: country,
          );
      state = state.copyWith(
        isLoading: false,
        jobs: jobs,
        hasMore: jobs.isNotEmpty,
      );
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
            employmentTypes: state.selectedEmploymentTypes.isEmpty
                ? null
                : state.selectedEmploymentTypes,
            remoteOnly: state.remoteOnly,
            datePosted: state.datePosted,
            country: state.country,
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

final jobSearchProvider =
    NotifierProvider<JobSearchNotifier, JobSearchState>(JobSearchNotifier.new);
