// lib/models/job_model.dart
import 'package:hive/hive.dart';

part 'job_model.g.dart';

class JobModel {
  final String? jobId;
  final String? employerName;
  final String? employerLogo;
  final String? jobTitle;
  final String? jobDescription;
  final String? jobCity;
  final String? jobState;
  final String? jobCountry;
  final String? jobEmploymentType;
  final String? jobApplyLink;
  final String? jobPublisher;
  final String? jobPostedAtTimestamp;

  JobModel({
    this.jobId,
    this.employerName,
    this.employerLogo,
    this.jobTitle,
    this.jobDescription,
    this.jobCity,
    this.jobState,
    this.jobCountry,
    this.jobEmploymentType,
    this.jobApplyLink,
    this.jobPublisher,
    this.jobPostedAtTimestamp,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: json['job_id'],
      employerName: json['employer_name'],
      employerLogo: json['employer_logo'],
      jobTitle: json['job_title'],
      jobDescription: json['job_description'],
      jobCity: json['job_city'],
      jobState: json['job_state'],
      jobCountry: json['job_country'],
      jobEmploymentType: json['job_employment_type'],
      jobApplyLink: json['job_apply_link'],
      jobPublisher: json['job_publisher'],
      jobPostedAtTimestamp: json['job_posted_at_timestamp']?.toString(),
    );
  }

  SavedJobModel toSavedJobModel() {
    return SavedJobModel(
      jobId: jobId ?? '',
      jobTitle: jobTitle ?? '',
      companyName: employerName ?? '',
      companyLogo: employerLogo,
      location: '${jobCity ?? ''}, ${jobState ?? ''}',
      applyLink: jobApplyLink ?? '',
      employmentType: jobEmploymentType ?? '',
    );
  }
}

@HiveType(typeId: 1)
class SavedJobModel extends HiveObject {
  @HiveField(0)
  final String jobId;
  @HiveField(1)
  final String jobTitle;
  @HiveField(2)
  final String companyName;
  @HiveField(3)
  final String? companyLogo;
  @HiveField(4)
  final String location;
  @HiveField(5)
  final String applyLink;
  @HiveField(6)
  final String employmentType;

  SavedJobModel({
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogo,
    required this.location,
    required this.applyLink,
    required this.employmentType,
  });
}
