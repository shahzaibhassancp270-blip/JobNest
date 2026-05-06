// lib/features/analytics/presentation/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobnest/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:jobnest/features/analytics/presentation/widgets/analytics_chart.dart';
import 'package:jobnest/core/constants/app_colors.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatCard(context, 'Total Apps', '${analytics.totalApplications}', Icons.work_outline, AppColors.primary),
                const SizedBox(width: 16),
                _buildStatCard(context, 'Response Rate', '${analytics.responseRate.toStringAsFixed(1)}%', Icons.reply, AppColors.secondary),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Status Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnalyticsPieChart(data: analytics.statusCount),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Applications per Day (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnalyticsBarChart(data: analytics.weeklyStats),
              ),
            ),
            const SizedBox(height: 32),
            _buildOfferRateCard(context, analytics.offerRate),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0: context.push('/'); break;
            case 1: context.push('/tracker'); break;
            case 2: context.push('/saved'); break;
            case 3: break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.view_kanban_outlined), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferRateCard(BuildContext context, double rate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Offer Success Rate', style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 4),
                Text('Keep pushing! You are doing great.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${rate.toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
