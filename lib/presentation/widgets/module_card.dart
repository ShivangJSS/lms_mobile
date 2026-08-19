import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
import '../../domain/entities/learning_module.dart';

/// Single row in the module list, styled as a glossy card. Locked modules are
/// not tappable and read as a muted, flat tile.
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
    final locked = module.isLocked;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: locked
          ? AppGloss.panel(r: AppGloss.radius)
          : AppGloss.card(r: AppGloss.radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppGloss.radius),
        child: InkWell(
          onTap: locked ? null : onTap,
          borderRadius: BorderRadius.circular(AppGloss.radius),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _ModuleBadge(locked: locked),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.moduleName,
                        style: AppText.h4.copyWith(
                          color: locked
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Duration : ${module.durationText}',
                            style: AppText.muted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatusIcon(status: module.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glossy leading badge. Brand gradient for open modules, muted for locked.
class _ModuleBadge extends StatelessWidget {
  final bool locked;

  const _ModuleBadge({required this.locked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: locked ? null : AppColors.brandGradientRich,
        color: locked ? AppColors.tintedPanel : null,
        borderRadius: BorderRadius.circular(AppGloss.radiusSm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: locked ? null : AppGloss.soft,
      ),
      child: Stack(
        children: [
          if (!locked) AppGloss.sheen(r: AppGloss.radiusSm),
          Center(
            child: Icon(
              Icons.article_rounded,
              color: locked
                  ? AppColors.textSecondary.withValues(alpha: 0.7)
                  : Colors.white,
              size: 24,
            ),
          ),
        ],
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
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.progressGreen.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.progressGreen.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.progressGreen.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF4E8B1C),
            size: 20,
          ),
        );

      case ModuleStatus.active:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            gradient: AppColors.buttonGloss,
            shape: BoxShape.circle,
            boxShadow: AppGloss.buttonGlow,
          ),
          child: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 15,
          ),
        );

      case ModuleStatus.locked:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.hairline),
          ),
          child: Icon(
            Icons.lock_rounded,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            size: 16,
          ),
        );
    }
  }
}
