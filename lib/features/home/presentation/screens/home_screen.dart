// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/features/home/presentation/providers/job_search_provider.dart';
import 'package:jobnest/features/home/presentation/widgets/job_card.dart';
import 'package:jobnest/core/widgets/loading_shimmer.dart';
import 'package:jobnest/core/utils/location_service.dart';
import 'package:jobnest/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _locationService = LocationService();
  
  bool _remoteOnly = false;
  String _employmentType = 'FULLTIME';
  String? _currentCity;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeSearch();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(jobSearchProvider.notifier).loadMore();
    }
  }

  Future<void> _initializeSearch() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      _currentCity = await _locationService.getCityFromPosition(position);
    }

    final user = ref.read(userProvider);
    final initialQuery = user?.displayName != null ? "Jobs for ${user!.displayName}" : "Flutter Developer";
    
    _performSearch(initialQuery);
  }

  void _performSearch([String? query]) {
    ref.read(jobSearchProvider.notifier).searchJobs(
      query ?? _searchController.text,
      location: _currentCity,
      remoteOnly: _remoteOnly,
      employmentType: _employmentType,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(jobSearchProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${user?.displayName?.split(' ').first ?? 'User'} 👋',
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
            const Text('Find your dream job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (_currentCity != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: const Icon(Icons.location_on, size: 14, color: Colors.blue),
                label: Text(_currentCity!, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue.withOpacity(0.05),
                side: BorderSide.none,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: searchState.isLoading && searchState.jobs.isEmpty
                ? const LoadingShimmer()
                : RefreshIndicator(
                    onRefresh: () async => _performSearch(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: searchState.jobs.length + (searchState.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == searchState.jobs.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                        }
                        final job = searchState.jobs[index];
                        return JobCard(
                          job: job,
                          onTap: () => context.push('/job-detail', extra: job),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0: break;
            case 1: context.push('/tracker'); break;
            case 2: context.push('/saved'); break;
            case 3: context.push('/analytics'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.view_kanban_outlined), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline_rounded), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Job title, company, or keywords...',
              prefixIcon: const Icon(Icons.search, size: 22),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                  onPressed: () {
                    // Show advanced filters bottom sheet
                  },
                ),
              ),
            ),
            onSubmitted: (val) => _performSearch(val),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Remote'),
                  selected: _remoteOnly,
                  onSelected: (val) {
                    setState(() => _remoteOnly = val);
                    _performSearch();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Full-time'),
                  selected: _employmentType == 'FULLTIME',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _employmentType = 'FULLTIME');
                      _performSearch();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Contract'),
                  selected: _employmentType == 'CONTRACTOR',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _employmentType = 'CONTRACTOR');
                      _performSearch();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Part-time'),
                  selected: _employmentType == 'PARTTIME',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _employmentType = 'PARTTIME');
                      _performSearch();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
