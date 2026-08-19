import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
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
            decoration: AppGloss.card(r: AppGloss.radius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradientRich,
                        borderRadius: BorderRadius.circular(AppGloss.radiusSm),
                        boxShadow: AppGloss.soft,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Module Overview',
                      style: AppText.h3.copyWith(color: AppColors.primary),
                    ),
                  ],
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

/// Brand-gradient section bar used for the module name, Topics and similar
/// headings, with a glossy top sheen.
class SectionBanner extends StatelessWidget {
  final String title;

  const SectionBanner({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientRich,
        borderRadius: BorderRadius.circular(AppGloss.radius),
        boxShadow: AppGloss.soft,
      ),
      child: Stack(
        children: [
          AppGloss.sheen(r: AppGloss.radius),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Text(title, style: AppText.sectionTitle),
          ),
        ],
      ),
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
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: AppGloss.card(r: AppGloss.radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradientRich,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggle,
                child: Stack(
                  children: [
                    AppGloss.sheen(r: AppGloss.radius),
                    Padding(
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
                            open
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
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
      ),
    );
  }
}
