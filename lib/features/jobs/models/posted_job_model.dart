// lib/features/jobs/models/posted_job_model.dart
class PostedJobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String employmentType;
  final String salary;
  final String applyContact; // email or phone
  final String postedByUid;
  final String postedByName;
  final DateTime postedAt;

  PostedJobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.employmentType,
    required this.salary,
    required this.applyContact,
    required this.postedByUid,
    required this.postedByName,
    required this.postedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'company': company,
        'location': location,
        'description': description,
        'employmentType': employmentType,
        'salary': salary,
        'applyContact': applyContact,
        'postedByUid': postedByUid,
        'postedByName': postedByName,
        'postedAt': postedAt.toIso8601String(),
      };

  factory PostedJobModel.fromMap(Map<String, dynamic> map) => PostedJobModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        company: map['company'] ?? '',
        location: map['location'] ?? '',
        description: map['description'] ?? '',
        employmentType: map['employmentType'] ?? 'FULLTIME',
        salary: map['salary'] ?? 'Not specified',
        applyContact: map['applyContact'] ?? '',
        postedByUid: map['postedByUid'] ?? '',
        postedByName: map['postedByName'] ?? 'Anonymous',
        postedAt: DateTime.tryParse(map['postedAt'] ?? '') ?? DateTime.now(),
      );
}
