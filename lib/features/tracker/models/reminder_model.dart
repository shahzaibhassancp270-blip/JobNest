// lib/models/reminder_model.dart
import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 2)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String applicationId;
  @HiveField(2)
  final String jobTitle;
  @HiveField(3)
  final String companyName;
  @HiveField(4)
  final DateTime dateTime;
  @HiveField(5)
  final bool isActive;

  ReminderModel({
    required this.id,
    required this.applicationId,
    required this.jobTitle,
    required this.companyName,
    required this.dateTime,
    this.isActive = true,
  });
}
