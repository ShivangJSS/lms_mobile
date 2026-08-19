import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
import '../../domain/entities/learning_module.dart';

/// One tab per module_type returned by GET /mobile/module/types.
class ModuleTypeTabs extends StatelessWidget {
  final List<ModuleCategory> categories;
  final int? selectedTypeId;
  final ValueChanged<int?> onSelected;

  const ModuleTypeTabs({
    super.key,
    required this.categories,
    required this.selectedTypeId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          for (final category in categories) ...[
            Expanded(
              child: _Tab(
                label: category.moduleType,
                isActive: selectedTypeId == category.moduleTypeId,
                onTap: () => onSelected(category.moduleTypeId),
              ),
            ),
            if (category != categories.last) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppGloss.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppGloss.radius),
        child: DecoratedBox(
          decoration: isActive
              ? AppGloss.button(r: AppGloss.radius)
              : BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppGloss.radius),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  boxShadow: AppGloss.soft,
                ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isActive) AppGloss.sheen(r: AppGloss.radius),
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                alignment: Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.label.copyWith(
                    color: isActive ? AppColors.textWhite : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
