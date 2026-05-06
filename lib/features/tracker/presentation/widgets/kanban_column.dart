// lib/features/tracker/presentation/widgets/kanban_column.dart
import 'package:flutter/material.dart';
import 'package:jobnest/features/tracker/models/application_model.dart';
import 'package:jobnest/core/widgets/status_badge.dart';
import 'package:jobnest/core/constants/app_colors.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final List<ApplicationModel> applications;
  final Function(ApplicationModel) onTap;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.applications,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.2),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${applications.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                return GestureDetector(
                  onTap: () => onTap(app),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (app.companyLogo != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      app.companyLogo!,
                                      fit: BoxFit.contain,
                                      cacheWidth: 72,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.business_rounded,
                                          size: 20,
                                          color: AppColors.primary),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(Icons.business_rounded,
                                      size: 20, color: AppColors.primary),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.companyName,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    app.jobTitle,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            StatusBadge(status: app.status),
                            const Spacer(),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.grey[400], size: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
