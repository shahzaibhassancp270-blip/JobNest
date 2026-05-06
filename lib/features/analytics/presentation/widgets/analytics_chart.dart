// lib/features/analytics/presentation/widgets/analytics_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jobnest/core/constants/app_colors.dart';
import 'package:jobnest/features/analytics/presentation/providers/analytics_provider.dart';

class AnalyticsPieChart extends StatelessWidget {
  final Map<String, int> data;
  const AnalyticsPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [];
    final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, Colors.blue, AppColors.error];
    int index = 0;

    data.forEach((status, count) {
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[index % colors.length],
            value: count.toDouble(),
            title: '$count',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
      index++;
    });

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}

class AnalyticsBarChart extends StatelessWidget {
  final List<DailyCount> data;
  const AnalyticsBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < data.length) {
                    return Text(data[value.toInt()].day, style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.count.toDouble(),
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
