import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/core/constants/app_colors.dart';
import 'package:jobnest/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobnest/features/onboarding/data/preferences_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _prefsService = PreferencesService();
  final _cityController = TextEditingController();
  bool _isLoading = false;

  String _selectedCategory = 'Software Engineer';
  String _selectedType = 'FULLTIME';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Software Engineer', 'icon': Icons.code_rounded},
    {'label': 'Data Scientist', 'icon': Icons.analytics_rounded},
    {'label': 'Product Manager', 'icon': Icons.dashboard_rounded},
    {'label': 'UI/UX Designer', 'icon': Icons.design_services_rounded},
    {'label': 'Marketing', 'icon': Icons.campaign_rounded},
    {'label': 'Finance', 'icon': Icons.account_balance_rounded},
    {'label': 'Sales', 'icon': Icons.trending_up_rounded},
    {'label': 'HR Manager', 'icon': Icons.people_rounded},
    {'label': 'DevOps Engineer', 'icon': Icons.cloud_rounded},
    {'label': 'Cybersecurity', 'icon': Icons.security_rounded},
  ];

  final List<Map<String, dynamic>> _employmentTypes = [
    {'label': 'Full-time', 'value': 'FULLTIME'},
    {'label': 'Part-time', 'value': 'PARTTIME'},
    {'label': 'Contract', 'value': 'CONTRACTOR'},
    {'label': 'Internship', 'value': 'INTERN'},
  ];

  Future<void> _saveAndContinue() async {
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your city')),
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work_rounded, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Builder(builder: (context) {
                final user = ref.watch(userProvider);
                final firstName = user?.displayName?.split(' ').first ?? 'there';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $firstName! 🎉',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tell us what you\'re looking for so we can show the best jobs for you.',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 40),

              // --- City ---
              const Text('📍 Your City', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'e.g. Lahore, Karachi, Islamabad',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              // --- Job Category ---
              const Text('💼 What job are you looking for?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(cat['icon'] as IconData,
                              color: isSelected ? Colors.white : Colors.grey[700], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat['label'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[800],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // --- Employment Type ---
              const Text('⏱ Employment Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: _employmentTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type['value']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          type['label'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveAndContinue,
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Find My Jobs →'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
