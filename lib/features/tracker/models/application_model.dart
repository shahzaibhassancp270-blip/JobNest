// lib/features/tracker/models/application_model.dart
import 'package:hive/hive.dart';

part 'application_model.g.dart';

@HiveType(typeId: 0)
class ApplicationModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String jobTitle;
  @HiveField(2)
  final String companyName;
  @HiveField(3)
  final String jobUrl;
  @HiveField(4)
  final String status; // Saved, Applied, Interview, Offer, Rejected
  @HiveField(5)
  final String notes;
  @HiveField(6)
  final String resumeLink;
  @HiveField(7)
  final DateTime appliedDate;
  @HiveField(8)
  final DateTime? interviewDate;
  @HiveField(9)
  final String? companyLogo;

  ApplicationModel({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.jobUrl,
    required this.status,
    required this.notes,
    required this.resumeLink,
    required this.appliedDate,
    this.interviewDate,
    this.companyLogo,
  });

  ApplicationModel copyWith({
    String? status,
    String? notes,
    String? resumeLink,
    DateTime? interviewDate,
    String? companyLogo,
  }) {
    return ApplicationModel(
      id: id,
      jobTitle: jobTitle,
      companyName: companyName,
      jobUrl: jobUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      resumeLink: resumeLink ?? this.resumeLink,
      appliedDate: appliedDate,
      interviewDate: interviewDate ?? this.interviewDate,
      companyLogo: companyLogo ?? this.companyLogo,
    );
  }
}
