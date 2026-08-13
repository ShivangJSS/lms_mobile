import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
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
      padding: const EdgeInsets.all(16.0),
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
