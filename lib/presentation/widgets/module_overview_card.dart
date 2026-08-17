import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/learning_module.dart';

/// Module name banner, the always-open Module Overview card, and the
/// collapsible Learning Objective section.
class ModuleOverviewCard extends StatefulWidget {
  final ModuleOverviewInfo overview;
  final int languageId;

  const ModuleOverviewCard({
    super.key,
    required this.overview,
    required this.languageId,
  });

  @override
  State<ModuleOverviewCard> createState() => _ModuleOverviewCardState();
}

class _ModuleOverviewCardState extends State<ModuleOverviewCard> {
  bool _objectiveOpen = false;

  @override
  Widget build(BuildContext context) {
    final overview = widget.overview;

    final overviewText = overview.moduleOverview?.trim().isNotEmpty == true
        ? overview.moduleOverview!
        : (overview.moduleDescription ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionBanner(title: overview.moduleName ?? ''),
        if (overviewText.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module Overview',
                  style: AppText.h3.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  overviewText,
                  style: AppText.body,
                ),
              ],
            ),
          ),
        ],
        if (overview.moduleObjective?.trim().isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.md),
          _Collapsible(
            title: 'Learning Objective',
            open: _objectiveOpen,
            onToggle: () => setState(() => _objectiveOpen = !_objectiveOpen),
            body: overview.moduleObjective!,
          ),
        ],
      ],
    );
  }
}

/// Muted purple bar used for the module name, Topics and similar headings.
class SectionBanner extends StatelessWidget {
  final String title;

  const SectionBanner({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.sectionHeader,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Text(title, style: AppText.sectionTitle),
    );
  }
}

class _Collapsible extends StatelessWidget {
  final String title;
  final String body;
  final bool open;
  final VoidCallback onToggle;

  const _Collapsible({
    required this.title,
    required this.body,
    required this.open,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.sectionHeader,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppText.sectionTitle,
                    ),
                  ),
                  Icon(
                    open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState:
              open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(
              body,
              style: AppText.body,
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
