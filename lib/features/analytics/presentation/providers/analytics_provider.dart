// lib/features/analytics/presentation/providers/analytics_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobnest/features/tracker/models/application_model.dart';
import 'package:jobnest/features/tracker/presentation/providers/applications_provider.dart';
import 'package:intl/intl.dart';

class AnalyticsData {
  final Map<String, int> statusCount;
  final List<DailyCount> weeklyStats;
  final int totalApplications;
  final double responseRate;
  final double offerRate;

  AnalyticsData({
    required this.statusCount,
    required this.weeklyStats,
    required this.totalApplications,
    required this.responseRate,
    required this.offerRate,
  });
}

class DailyCount {
  final String day;
  final int count;
  DailyCount(this.day, this.count);
}

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final applications = ref.watch(applicationsProvider);
  
  // Status breakdown
  final Map<String, int> statusCount = {
    'Saved': 0,
    'Applied': 0,
    'Interview': 0,
    'Offer': 0,
    'Rejected': 0,
  };
  
  for (var app in applications) {
    statusCount[app.status] = (statusCount[app.status] ?? 0) + 1;
  }

  // Weekly stats
  final last7Days = List.generate(7, (index) {
    final date = DateTime.now().subtract(Duration(days: index));
    return DateFormat('EEE').format(date);
  }).reversed.toList();

  final Map<String, int> dailyCounts = {};
  for (var day in last7Days) dailyCounts[day] = 0;

  for (var app in applications) {
    final appDay = DateFormat('EEE').format(app.appliedDate);
    if (dailyCounts.containsKey(appDay)) {
      dailyCounts[appDay] = dailyCounts[appDay]! + 1;
    }
  }

  final weeklyStats = last7Days.map((day) => DailyCount(day, dailyCounts[day]!)).toList();

  // Metrics
  final total = applications.length;
  final responses = (statusCount['Interview'] ?? 0) + (statusCount['Offer'] ?? 0);
  final offers = statusCount['Offer'] ?? 0;

  return AnalyticsData(
    statusCount: statusCount,
    weeklyStats: weeklyStats,
    totalApplications: total,
    responseRate: total == 0 ? 0 : (responses / total) * 100,
    offerRate: total == 0 ? 0 : (offers / total) * 100,
  );
});
