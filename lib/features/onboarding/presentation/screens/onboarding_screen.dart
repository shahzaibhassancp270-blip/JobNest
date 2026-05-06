// lib/features/onboarding/presentation/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/core/constants/app_colors.dart';
import 'package:jobnest/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobnest/features/onboarding/data/preferences_service.dart';
import 'package:jobnest/core/utils/location_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _prefsService = PreferencesService();
  final _locationService = LocationService();
  final _cityController = TextEditingController();
  bool _isLoading = false;
  bool _isDetectingLocation = false;

  String _selectedCategory = 'Software Engineer';
  String _selectedType = 'FULLTIME';

  // All industries — not just IT!
  final List<Map<String, dynamic>> _categories = [
    // Technology
    {'label': 'Software Engineer', 'icon': Icons.code_rounded, 'color': 0xFF6366F1},
    {'label': 'Data Scientist', 'icon': Icons.analytics_rounded, 'color': 0xFF6366F1},
    {'label': 'UI/UX Designer', 'icon': Icons.design_services_rounded, 'color': 0xFF6366F1},
    {'label': 'DevOps Engineer', 'icon': Icons.cloud_rounded, 'color': 0xFF6366F1},
    {'label': 'Cybersecurity', 'icon': Icons.security_rounded, 'color': 0xFF6366F1},
    // Business
    {'label': 'Product Manager', 'icon': Icons.dashboard_rounded, 'color': 0xFF0EA5E9},
    {'label': 'Marketing', 'icon': Icons.campaign_rounded, 'color': 0xFF0EA5E9},
    {'label': 'Sales Executive', 'icon': Icons.trending_up_rounded, 'color': 0xFF0EA5E9},
    {'label': 'HR Manager', 'icon': Icons.people_rounded, 'color': 0xFF0EA5E9},
    {'label': 'Business Analyst', 'icon': Icons.bar_chart_rounded, 'color': 0xFF0EA5E9},
    // Finance
    {'label': 'Accountant', 'icon': Icons.calculate_rounded, 'color': 0xFF10B981},
    {'label': 'Financial Analyst', 'icon': Icons.account_balance_rounded, 'color': 0xFF10B981},
    {'label': 'Banker', 'icon': Icons.credit_card_rounded, 'color': 0xFF10B981},
    // Healthcare
    {'label': 'Doctor', 'icon': Icons.medical_services_rounded, 'color': 0xFFEF4444},
    {'label': 'Nurse', 'icon': Icons.health_and_safety_rounded, 'color': 0xFFEF4444},
    {'label': 'Pharmacist', 'icon': Icons.local_pharmacy_rounded, 'color': 0xFFEF4444},
    // Education
    {'label': 'Teacher', 'icon': Icons.school_rounded, 'color': 0xFFF59E0B},
    {'label': 'Professor', 'icon': Icons.cast_for_education_rounded, 'color': 0xFFF59E0B},
    {'label': 'Tutor', 'icon': Icons.menu_book_rounded, 'color': 0xFFF59E0B},
    // Engineering
    {'label': 'Civil Engineer', 'icon': Icons.architecture_rounded, 'color': 0xFF8B5CF6},
    {'label': 'Mechanical Engineer', 'icon': Icons.engineering_rounded, 'color': 0xFF8B5CF6},
    {'label': 'Electrical Engineer', 'icon': Icons.electric_bolt_rounded, 'color': 0xFF8B5CF6},
    // Creative
    {'label': 'Graphic Designer', 'icon': Icons.palette_rounded, 'color': 0xFFEC4899},
    {'label': 'Content Writer', 'icon': Icons.edit_note_rounded, 'color': 0xFFEC4899},
    {'label': 'Photographer', 'icon': Icons.camera_alt_rounded, 'color': 0xFFEC4899},
    // Legal
    {'label': 'Lawyer', 'icon': Icons.gavel_rounded, 'color': 0xFF64748B},
    // Hospitality
    {'label': 'Chef', 'icon': Icons.restaurant_rounded, 'color': 0xFFF97316},
    {'label': 'Hotel Manager', 'icon': Icons.hotel_rounded, 'color': 0xFFF97316},
    // Logistics
    {'label': 'Driver', 'icon': Icons.drive_eta_rounded, 'color': 0xFF06B6D4},
    {'label': 'Logistics Manager', 'icon': Icons.local_shipping_rounded, 'color': 0xFF06B6D4},
  ];

  final List<Map<String, dynamic>> _employmentTypes = [
    {'label': 'Full-time', 'value': 'FULLTIME', 'icon': Icons.work_rounded},
    {'label': 'Part-time', 'value': 'PARTTIME', 'icon': Icons.work_outline_rounded},
    {'label': 'Contract', 'value': 'CONTRACTOR', 'icon': Icons.handshake_rounded},
    {'label': 'Internship', 'value': 'INTERN', 'icon': Icons.school_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _autoDetectLocation();
  }

  Future<void> _autoDetectLocation() async {
    setState(() => _isDetectingLocation = true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final city = await _locationService.getCityFromPosition(position);
        if (mounted && city != null) {
          _cityController.text = city;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isDetectingLocation = false);
  }

  Future<void> _saveAndContinue() async {
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your city'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await _prefsService.savePreferences(
      jobCategory: _selectedCategory,
      city: _cityController.text.trim(),
      employmentType: _selectedType,
    );
    setState(() => _isLoading = false);

    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final firstName = user?.displayName?.split(' ').first ?? 'there';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF818CF8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.work_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome, $firstName! 🎉',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Tell us what kind of job you\'re looking for. We\'ll personalize everything for you.',
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              // --- City with GPS ---
              Row(
                children: [
                  const Text('📍 Your City',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  if (_isDetectingLocation)
                    const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    GestureDetector(
                      onTap: _autoDetectLocation,
                      child: Row(
                        children: [
                          Icon(Icons.my_location_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('Detect',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'e.g. Lahore, Karachi, Islamabad, Dubai',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),

              // --- Job Category ---
              const Text('💼 What are you looking for?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Select your job field',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['label'];
                  final color = Color(cat['color'] as int);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            color: isSelected ? Colors.white : color,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // --- Employment Type ---
              const Text('⏱ Employment Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.2,
                children: _employmentTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type['value']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(type['icon'] as IconData,
                              size: 16,
                              color: isSelected ? Colors.white : AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            type['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveAndContinue,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(_isLoading ? 'Saving...' : 'Find My Jobs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
