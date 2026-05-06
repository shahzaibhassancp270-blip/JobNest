// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/features/home/presentation/providers/job_search_provider.dart';
import 'package:jobnest/features/home/presentation/widgets/job_card.dart';
import 'package:jobnest/core/widgets/loading_shimmer.dart';
import 'package:jobnest/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobnest/features/onboarding/data/preferences_service.dart';
import 'package:jobnest/core/utils/location_service.dart';
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
  final _locationService = LocationService();

  String? _currentCity;
  String _jobCategory = 'Software Engineer';
  bool _useLocationFilter = true;

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
    final savedCity = await _prefsService.getCity();
    final empType = await _prefsService.getEmploymentType();

    // Try GPS first, fall back to saved city
    String? city = savedCity.isNotEmpty ? savedCity : null;
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final gpsCity = await _locationService.getCityFromPosition(position);
        if (gpsCity != null && gpsCity.isNotEmpty) {
          city = gpsCity;
          await _prefsService.updateCity(gpsCity); // keep in sync
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _jobCategory = category;
        _currentCity = city;
        _searchController.text = category;
      });
    }

    _performSearch(category, empType: empType);
  }

  void _performSearch(String? query, {bool respectLocation = true, String? empType}) {
    final searchQuery = query ?? _searchController.text;
    if (searchQuery.isEmpty) return;

    final location = (respectLocation && _useLocationFilter) ? _currentCity : null;
    final state = ref.read(jobSearchProvider);

    ref.read(jobSearchProvider.notifier).searchJobs(
          searchQuery,
          location: location,
          employmentTypes: empType != null ? [empType] : state.selectedEmploymentTypes,
          remoteOnly: state.remoteOnly,
          datePosted: state.datePosted,
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
            hintText: 'e.g. Lahore, Karachi, Dubai',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newCity = cityController.text.trim();
              await _prefsService.updateCity(newCity);
              if (mounted) {
                setState(() {
                  _currentCity = newCity.isEmpty ? null : newCity;
                  _useLocationFilter = newCity.isNotEmpty;
                });
                Navigator.pop(context);
                _performSearch(null);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(
        onApply: (empTypes, datePosted, remoteOnly) {
          ref.read(jobSearchProvider.notifier).searchJobs(
                _searchController.text.isNotEmpty
                    ? _searchController.text
                    : _jobCategory,
                location:
                    (_useLocationFilter ? _currentCity : null),
                employmentTypes: empTypes,
                remoteOnly: remoteOnly,
                datePosted: datePosted,
              );
        },
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
    final activeFilterCount = (searchState.remoteOnly ? 1 : 0) +
        searchState.selectedEmploymentTypes.length +
        (searchState.datePosted != 'all' ? 1 : 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // --- Premium AppBar ---
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, ${user?.displayName?.split(' ').first ?? 'there'} 👋',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Text(
                                    'Find Your Dream Job',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Avatar
                            GestureDetector(
                              onTap: () => context.push('/profile'),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: Text(
                                  (user?.displayName?.substring(0, 1) ?? 'U')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Location row
                        GestureDetector(
                          onTap: _showLocationDialog,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _currentCity ?? 'Set your city',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white70, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Search bar pinned below app bar ---
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Job title, skill, company...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.15),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (val) {
                        setState(() => _useLocationFilter = false);
                        _performSearch(val, respectLocation: false);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter button with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: _showFilterSheet,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: AppColors.primary, size: 22),
                        ),
                      ),
                      if (activeFilterCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$activeFilterCount',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Active filter chips ---
          if (activeFilterCount > 0)
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (searchState.remoteOnly)
                      _buildActiveChip('Remote', Icons.wifi_rounded),
                    ...searchState.selectedEmploymentTypes.map(
                      (t) => _buildActiveChip(t, Icons.work_outline_rounded),
                    ),
                    if (searchState.datePosted != 'all')
                      _buildActiveChip(_dateLabel(searchState.datePosted),
                          Icons.calendar_today_rounded),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(jobSearchProvider.notifier).searchJobs(
                              _jobCategory,
                              location: _useLocationFilter ? _currentCity : null,
                              employmentTypes: [],
                              remoteOnly: false,
                              datePosted: 'all',
                            );
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.close, size: 14, color: Colors.red),
                            SizedBox(width: 4),
                            Text('Clear all',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // --- Location toggle chip ---
          if (_currentCity != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    FilterChip(
                      avatar: Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: _useLocationFilter ? Colors.white : AppColors.primary,
                      ),
                      label: Text('Near $_currentCity'),
                      selected: _useLocationFilter,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _useLocationFilter ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() => _useLocationFilter = val);
                        _performSearch(null, respectLocation: val);
                      },
                    ),
                    const Spacer(),
                    Text(
                      '${searchState.jobs.length} jobs found',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          // --- Section title ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                _useLocationFilter && _currentCity != null
                    ? 'Jobs near $_currentCity'
                    : 'All Jobs',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // --- Job list ---
          searchState.isLoading && searchState.jobs.isEmpty
              ? const SliverFillRemaining(child: LoadingShimmer())
              : searchState.error != null && searchState.jobs.isEmpty
                  ? SliverFillRemaining(child: _buildError(searchState.error!))
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == searchState.jobs.length) {
                              return searchState.hasMore
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: CircularProgressIndicator.adaptive(),
                                      ),
                                    )
                                  : const SizedBox(height: 20);
                            }
                            final job = searchState.jobs[index];
                            return JobCard(
                              job: job,
                              onTap: () => context.push('/job-detail', extra: job),
                            );
                          },
                          childCount: searchState.jobs.length + 1,
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
            case 0: break;
            case 1: context.go('/tracker'); break;
            case 2: context.go('/saved'); break;
            case 3: context.go('/analytics'); break;
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

  Widget _buildActiveChip(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
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
          TextButton(onPressed: () => _performSearch(null), child: const Text('Try Again')),
        ],
      ),
    );
  }

  String _dateLabel(String key) {
    switch (key) {
      case 'today': return 'Today';
      case 'week': return 'This week';
      case 'month': return 'This month';
      default: return 'Any time';
    }
  }
}

// =========================================================
// FILTER BOTTOM SHEET
// =========================================================
class _FilterSheet extends ConsumerStatefulWidget {
  final void Function(List<String> empTypes, String datePosted, bool remoteOnly) onApply;

  const _FilterSheet({required this.onApply});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late List<String> _selectedTypes;
  late String _selectedDate;
  late bool _remoteOnly;

  final _empTypes = [
    {'label': 'Full-time', 'value': 'FULLTIME', 'icon': Icons.work_rounded},
    {'label': 'Part-time', 'value': 'PARTTIME', 'icon': Icons.work_outline_rounded},
    {'label': 'Contract', 'value': 'CONTRACTOR', 'icon': Icons.handshake_rounded},
    {'label': 'Internship', 'value': 'INTERN', 'icon': Icons.school_outlined},
  ];

  final _dates = [
    {'label': 'Any time', 'value': 'all'},
    {'label': 'Today', 'value': 'today'},
    {'label': 'This week', 'value': 'week'},
    {'label': 'This month', 'value': 'month'},
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(jobSearchProvider);
    _selectedTypes = List.from(state.selectedEmploymentTypes);
    _selectedDate = state.datePosted;
    _remoteOnly = state.remoteOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypes = [];
                      _selectedDate = 'all';
                      _remoteOnly = false;
                    });
                  },
                  child: const Text('Reset all'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Employment Type (multi-select) ---
            const Text('Employment Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Text('Select one or more',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _empTypes.map((type) {
                final isSelected = _selectedTypes.contains(type['value']);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTypes.remove(type['value']);
                      } else {
                        _selectedTypes.add(type['value'] as String);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type['icon'] as IconData,
                            size: 15,
                            color: isSelected ? Colors.white : AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          type['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded,
                              size: 14, color: Colors.white),
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // --- Date Posted (single select) ---
            const Text('Date Posted',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: _dates.map((date) {
                final isSelected = _selectedDate == date['value'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDate = date['value'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.secondary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        date['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // --- Remote toggle ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Remote Only',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Show only remote jobs',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _remoteOnly,
                    onChanged: (val) => setState(() => _remoteOnly = val),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: () {
                widget.onApply(_selectedTypes, _selectedDate, _remoteOnly);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_rounded),
              label: Text(
                'Apply Filters${_selectedTypes.isNotEmpty || _selectedDate != 'all' || _remoteOnly ? ' (${_selectedTypes.length + (_selectedDate != 'all' ? 1 : 0) + (_remoteOnly ? 1 : 0)})' : ''}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
