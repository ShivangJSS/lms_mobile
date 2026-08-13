import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFECCC),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFB74D),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.article,
            color: Color(0xFFFFB74D),
          ),
        ),
        title: Text(
          module.moduleName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Duration : ${module.durationText}',
            style: const TextStyle(color: Colors.grey),
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
