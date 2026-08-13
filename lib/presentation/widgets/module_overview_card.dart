import 'package:flutter/material.dart';

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
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Module Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  overviewText,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ],
        if (overview.moduleObjective?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.assessmentHeader,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.assessmentHeader,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
            child: Text(
              body,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
