// lib/features/jobs/presentation/screens/post_job_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/core/constants/app_colors.dart';
import 'package:jobnest/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobnest/features/jobs/data/posted_jobs_service.dart';
import 'package:jobnest/features/jobs/models/posted_job_model.dart';
import 'package:uuid/uuid.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _contactController = TextEditingController();
  final _service = PostedJobsService();

  String _selectedType = 'FULLTIME';
  bool _isLoading = false;

  final List<String> _employmentTypes = ['FULLTIME', 'PARTTIME', 'CONTRACTOR', 'INTERN'];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = ref.read(userProvider);

    try {
      final job = PostedJobModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        employmentType: _selectedType,
        salary: _salaryController.text.trim().isEmpty
            ? 'Not specified'
            : _salaryController.text.trim(),
        applyContact: _contactController.text.trim(),
        postedByUid: user?.uid ?? '',
        postedByName: user?.displayName ?? 'Anonymous',
        postedAt: DateTime.now(),
      );

      await _service.postJob(job);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Job posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.business_center_rounded, color: Colors.white, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'Hire Great Talent',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Post your job and reach thousands of candidates.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildField('Job Title *', 'e.g. Senior Flutter Developer', _titleController,
                  Icons.work_outline),
              _buildField('Company Name *', 'e.g. Tech Corp', _companyController,
                  Icons.business_outlined),
              _buildField('Location *', 'e.g. Lahore, Pakistan', _locationController,
                  Icons.location_on_outlined),

              const SizedBox(height: 20),
              const Text('Employment Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _employmentTypes.map((type) {
                  final isSelected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedType = type),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _buildField('Salary / Range', 'e.g. 80,000 - 120,000 PKR', _salaryController,
                  Icons.payments_outlined, required: false),
              _buildField(
                'Contact (Email or Phone) *',
                'e.g. hr@company.com',
                _contactController,
                Icons.contact_mail_outlined,
              ),

              const SizedBox(height: 8),
              const Text('Job Description *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Describe the role, responsibilities, and requirements...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _postJob,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: const Text('Post Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: required
                ? (val) => val == null || val.isEmpty ? 'Required' : null
                : null,
          ),
        ],
      ),
    );
  }
}
