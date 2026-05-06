// lib/features/tracker/presentation/screens/application_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jobnest/features/tracker/models/application_model.dart';
import 'package:jobnest/features/tracker/presentation/providers/applications_provider.dart';
import 'package:jobnest/core/utils/snackbar_helper.dart';
import 'package:jobnest/core/constants/app_colors.dart';

class ApplicationDetailScreen extends ConsumerStatefulWidget {
  final ApplicationModel application;
  const ApplicationDetailScreen({super.key, required this.application});

  @override
  ConsumerState<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState
    extends ConsumerState<ApplicationDetailScreen> {
  late TextEditingController _notesController;
  late TextEditingController _resumeController;
  late String _status;
  DateTime? _interviewDate;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.application.notes);
    _resumeController =
        TextEditingController(text: widget.application.resumeLink);
    _status = widget.application.status;
    _interviewDate = widget.application.interviewDate;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updatedApp = widget.application.copyWith(
      status: _status,
      notes: _notesController.text,
      resumeLink: _resumeController.text,
      interviewDate: _interviewDate,
    );
    await ref.read(applicationsProvider.notifier).updateApplication(updatedApp);
    if (mounted) {
      SnackBarHelper.showSuccess(context, 'Application updated');
      context.pop();
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _interviewDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_interviewDate ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _interviewDate = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        title: const Text(
          'Application Detail',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () async {
              // Show confirmation dialog before deleting
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Application?'),
                  content: const Text('This action cannot be undone.'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref
                    .read(applicationsProvider.notifier)
                    .deleteApplication(widget.application.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.application.companyLogo != null
                        ? Image.network(
                            widget.application.companyLogo!,
                            fit: BoxFit.contain,
                            cacheWidth: 112,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.business_rounded,
                                color: AppColors.primary,
                                size: 28),
                          )
                        : const Icon(Icons.business_rounded,
                            color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.application.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.application.jobTitle,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Status',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _status,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
              ),
              items: ['Saved', 'Applied', 'Interview', 'Offer', 'Rejected']
                  .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600))))
                  .toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
            const SizedBox(height: 24),

            const Text('Interview Date',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _interviewDate != null
                            ? DateFormat('MMM dd, yyyy - hh:mm a')
                                .format(_interviewDate!)
                            : 'Tap to set interview date',
                        style: TextStyle(
                            color: _interviewDate != null ? Colors.black87 : Colors.grey,
                            fontWeight: _interviewDate != null ? FontWeight.w600 : FontWeight.normal),
                      ),
                    ),
                    if (_interviewDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _interviewDate = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Resume Link',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            TextField(
              controller: _resumeController,
              decoration: InputDecoration(
                hintText: 'Link to your resume/portfolio',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.link_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Notes',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Add some notes about the application...',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Changes'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
