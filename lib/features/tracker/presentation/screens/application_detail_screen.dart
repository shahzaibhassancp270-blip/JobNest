// lib/features/tracker/presentation/screens/application_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jobnest/features/tracker/models/application_model.dart';
import 'package:jobnest/features/tracker/presentation/providers/applications_provider.dart';
import 'package:jobnest/core/utils/snackbar_helper.dart';

class ApplicationDetailScreen extends ConsumerStatefulWidget {
  final ApplicationModel application;
  const ApplicationDetailScreen({super.key, required this.application});

  @override
  ConsumerState<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends ConsumerState<ApplicationDetailScreen> {
  late TextEditingController _notesController;
  late TextEditingController _resumeController;
  late String _status;
  DateTime? _interviewDate;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.application.notes);
    _resumeController = TextEditingController(text: widget.application.resumeLink);
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
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_interviewDate ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _interviewDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              await ref.read(applicationsProvider.notifier).deleteApplication(widget.application.id);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.application.jobTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(widget.application.companyName, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 32),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
              items: ['Saved', 'Applied', 'Interview', 'Offer', 'Rejected'].map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
            const SizedBox(height: 24),
            const Text('Interview Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _interviewDate != null
                          ? DateFormat('MMM dd, yyyy - hh:mm a').format(_interviewDate!)
                          : 'Set Interview Date',
                    ),
                    const Spacer(),
                    if (_interviewDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _interviewDate = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Resume Link', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _resumeController,
              decoration: const InputDecoration(hintText: 'Link to your resume/portfolio'),
            ),
            const SizedBox(height: 24),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Add some notes about the application...'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
