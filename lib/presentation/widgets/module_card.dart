import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/learning_module.dart';

/// Single row in the module list. Locked modules are not tappable.
class ModuleCard extends StatelessWidget {
  final LearningModule module;
  final VoidCallback? onTap;

  const ModuleCard({
    super.key,
    required this.module,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.tintedPanel,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Icon(Icons.article, color: AppColors.primary),
        ),
        title: Text(module.moduleName, style: AppText.h4),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Duration : ${module.durationText}',
            style: AppText.muted,
          ),
        ),
        trailing: _StatusIcon(status: module.status),
        onTap: module.isLocked ? null : onTap,
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final ModuleStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ModuleStatus.completed:
        return const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          radius: 16,
          child: Icon(
            Icons.check,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
        );

      case ModuleStatus.active:
        return const CircleAvatar(
          backgroundColor: Color(0xFFE1BEE7),
          radius: 16,
          child: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 16,
          ),
        );

      case ModuleStatus.locked:
        return const CircleAvatar(
          backgroundColor: Color(0xFFEEEEEE),
          radius: 16,
          child: Icon(
            Icons.lock,
            color: Colors.grey,
            size: 16,
          ),
        );
    }
  }
}
