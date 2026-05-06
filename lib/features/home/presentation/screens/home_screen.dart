// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/features/home/presentation/providers/job_search_provider.dart';
import 'package:jobnest/features/home/presentation/widgets/job_card.dart';
import 'package:jobnest/core/widgets/loading_shimmer.dart';
import 'package:jobnest/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobnest/features/onboarding/data/preferences_service.dart';
import 'package:jobnest/core/constants/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _prefsService = PreferencesService();

  bool _remoteOnly = false;
  String _employmentType = 'FULLTIME';
  String? _currentCity;
  String _jobCategory = 'Software Engineer';
  bool _useLocationFilter = true; // true = filter by city, false = search everywhere

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPreferencesAndSearch();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(jobSearchProvider.notifier).loadMore();
    }
  }

  Future<void> _loadPreferencesAndSearch() async {
    // Load saved preferences
    final category = await _prefsService.getJobCategory();
    final city = await _prefsService.getCity();
    final empType = await _prefsService.getEmploymentType();

    if (mounted) {
      setState(() {
        _jobCategory = category;
        _currentCity = city.isNotEmpty ? city : null;
        _employmentType = empType;
        _searchController.text = category;
      });
    }

    _performSearch(category);
  }

  void _performSearch([String? query, bool respectLocationToggle = true]) {
    final searchQuery = query ?? _searchController.text;
    if (searchQuery.isEmpty) return;

    // Only pass city if the location filter is ON
    final location = (respectLocationToggle && _useLocationFilter) ? _currentCity : null;

    ref.read(jobSearchProvider.notifier).searchJobs(
          searchQuery,
          location: location,
          remoteOnly: _remoteOnly,
          employmentType: _employmentType,
        );
  }

  Future<void> _showLocationDialog() async {
    final cityController = TextEditingController(text: _currentCity ?? '');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Location'),
        content: TextField(
          controller: cityController,
          decoration: const InputDecoration(
            hintText: 'e.g. Lahore, Karachi, Islamabad',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCity = cityController.text.trim();
              await _prefsService.updateCity(newCity);
              if (mounted) {
                setState(() => _currentCity = newCity.isEmpty ? null : newCity);
                Navigator.pop(context);
                _performSearch();
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
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
              style: const TextStyle(
                  fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
            const Text('Find your dream job',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // Location chip — tappable to change city
          GestureDetector(
            onTap: _showLocationDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    _currentCity ?? 'Set City',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.expand_more, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: searchState.isLoading && searchState.jobs.isEmpty
                ? const LoadingShimmer()
                : searchState.error != null && searchState.jobs.isEmpty
                    ? _buildError(searchState.error!)
                    : RefreshIndicator(
                        onRefresh: () async => _performSearch(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              searchState.jobs.length + (searchState.hasMore ? 1 : 0),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/post-job'),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Post a Job'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go('/tracker');
              break;
            case 2:
              context.go('/saved');
              break;
            case 3:
              context.go('/analytics');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_kanban_outlined), label: 'Tracker'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline_rounded), label: 'Saved'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
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
                  icon: const Icon(Icons.search, color: Colors.white, size: 20),
                  onPressed: () => _performSearch(),
                ),
              ),
            ),
            onSubmitted: (val) {
              // Manual search: search globally (ignore city filter)
              setState(() => _useLocationFilter = false);
              _performSearch(val, false);
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Location toggle chip
                if (_currentCity != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        Icons.location_on,
                        size: 14,
                        color: _useLocationFilter ? Colors.white : null,
                      ),
                      label: Text('Near $_currentCity'),
                      selected: _useLocationFilter,
                      onSelected: (val) {
                        setState(() => _useLocationFilter = val);
                        _performSearch();
                      },
                    ),
                  ),
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

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Could not load jobs', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _performSearch(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
