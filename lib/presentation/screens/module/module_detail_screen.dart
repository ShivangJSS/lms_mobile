import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../domain/entities/learning_module.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/module_topics_view_model.dart';
import '../viewer/topic_viewer_screen.dart';

/// Faint decorative bubble bleeding off the header edges (matches the
/// feedback screen header).
Widget _headerBubble(double size) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: 0.06),
    ),
  );
}

class ModuleDetailScreen extends ConsumerWidget {
  final int moduleId;
  final String moduleName;

  const ModuleDetailScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moduleTopicsViewModelProvider(moduleId));
    final viewModel =
        ref.read(moduleTopicsViewModelProvider(moduleId).notifier);
    final lang = ref.watch(languageProvider).languageId;

    // Content starts below the header (status bar + app bar) since the glossy
    // header is drawn behind the body.
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Women With Wheels'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: AppGloss.header(r: 28),
          child: Stack(
            children: [
              Positioned(top: -46, right: -30, child: _headerBubble(150)),
              Positioned(bottom: -50, left: -40, child: _headerBubble(130)),
            ],
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.pageWash),
        child: Builder(
        builder: (context) {
          if (state.isLoading && state.topics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return _Message(
              text: state.error!,
              languageId: lang,
              onRetry: viewModel.load,
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: viewModel.load,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg, topInset + AppSpacing.lg, AppSpacing.lg,
                      AppSpacing.sm),
                    children: [
                      if (state.overview != null)
                        _ModuleOverview(
                          overview: state.overview!,
                          languageId: lang,
                        )
                      else
                        _SectionBar(title: moduleName),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionBar(
                        title: AppStrings.of('topics', lang),
                        icon: Icons.list_alt_rounded,
                        trailingCount:
                            state.topics.isEmpty ? null : state.topics.length,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (state.topics.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: Text(
                              'No topics have been published yet.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        for (var i = 0; i < state.topics.length; i++)
                          _TopicRow(
                            topic: state.topics[i],
                            onTap: () => _openTopic(context, state.topics[i]),
                          ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              _PostAssessmentBar(
                moduleId: moduleId,
                moduleName: state.overview?.moduleName ?? moduleName,
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  /// Opens the document itself rather than describing where it lives.
  void _openTopic(BuildContext context, ModuleTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopicViewerScreen(topic: topic),
      ),
    );
  }
}

/// Module name banner, the always-open overview description card, and the
/// collapsible Learning Objective section. Presentation only — the expand /
/// collapse state lives here just as it did in the shared widget.
class _ModuleOverview extends StatefulWidget {
  final ModuleOverviewInfo overview;
  final int languageId;

  const _ModuleOverview({
    required this.overview,
    required this.languageId,
  });

  @override
  State<_ModuleOverview> createState() => _ModuleOverviewState();
}

class _ModuleOverviewState extends State<_ModuleOverview> {
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
        _SectionBar(title: overview.moduleName ?? ''),
        if (overviewText.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _DescriptionCard(text: overviewText),
        ],
        if (overview.moduleObjective?.trim().isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.md),
          _LearningObjective(
            title: 'Learning Objective',
            body: overview.moduleObjective!,
            open: _objectiveOpen,
            onToggle: () => setState(() => _objectiveOpen = !_objectiveOpen),
          ),
        ],
      ],
    );
  }
}

/// Raised white glossy card carrying the module overview copy, led by a small
/// brand-gradient icon chip.
class _DescriptionCard extends StatelessWidget {
  final String text;

  const _DescriptionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppGloss.card(r: AppGloss.radius, shadow: AppGloss.lifted),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconChip(icon: Icons.menu_book_rounded),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Module Overview',
                style: AppText.h3.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(text, style: AppText.body),
        ],
      ),
    );
  }
}

/// A small raised brand-gradient chip holding a white icon, top-lit for depth.
class _IconChip extends StatelessWidget {
  final IconData icon;

  const _IconChip({required this.icon});

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientRich,
        borderRadius: BorderRadius.circular(AppGloss.radiusSm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: AppGloss.soft,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppGloss.sheen(r: AppGloss.radiusSm),
          Icon(icon, color: Colors.white, size: size * 0.54),
        ],
      ),
    );
  }
}

/// Glossy brand-gradient section bar for the module name and "Topics", with a
/// wet top sheen, an optional leading icon and an optional trailing count pill.
class _SectionBar extends StatelessWidget {
  final String title;
  final IconData? icon;
  final int? trailingCount;

  const _SectionBar({
    required this.title,
    this.icon,
    this.trailingCount,
  });

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
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(title, style: AppText.sectionTitle),
                ),
                if (trailingCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '$trailingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible Learning Objective: a glossy plum header bar with a chevron over
/// a raised white card body that fades open and closed.
class _LearningObjective extends StatelessWidget {
  final String title;
  final String body;
  final bool open;
  final VoidCallback onToggle;

  const _LearningObjective({
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
                          const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(title, style: AppText.sectionTitle),
                          ),
                          AnimatedRotation(
                            turns: open ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
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
              child: Text(body, style: AppText.body),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// A topic row rendered as a raised white glossy card: media badge, title, and
/// a crisp chevron inside a subtle plum-tint circle.
class _TopicRow extends StatelessWidget {
  final ModuleTopic topic;
  final VoidCallback? onTap;

  const _TopicRow({required this.topic, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: AppGloss.card(r: AppGloss.radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppGloss.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppGloss.radius),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _MediaBadge(topic: topic),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    topic.topicName ?? 'Untitled topic',
                    style: AppText.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clean rounded media-type badge: a plum play-circle for video, an orange PPT
/// tile, a red PDF tile, and a plum DOC tile for anything else.
class _MediaBadge extends StatelessWidget {
  final ModuleTopic topic;

  const _MediaBadge({required this.topic});

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    if (topic.isVideo) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradientRich,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: AppGloss.soft,
        ),
        child: const Stack(
          children: [
            _CircleSheen(size: size),
            Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: size * 0.58,
              ),
            ),
          ],
        ),
      );
    }

    // A topic with no doc_type is not a presentation — it gets its own neutral
    // badge rather than being mislabelled PPT.
    final label = topic.isPdf
        ? 'PDF'
        : topic.isPpt
            ? 'PPT'
            : 'DOC';

    final baseColour = topic.isPdf
        ? const Color(0xFFE53935)
        : topic.isPpt
            ? const Color(0xFFE64A19)
            : AppColors.primaryLight;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(baseColour, Colors.white, 0.18)!,
            baseColour,
          ],
        ),
        borderRadius: BorderRadius.circular(AppGloss.radiusSm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: AppGloss.soft,
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          AppGloss.sheen(r: AppGloss.radiusSm),
          Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: size * 0.24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A soft top highlight clipped to a circular badge.
class _CircleSheen extends StatelessWidget {
  final double size;

  const _CircleSheen({required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(size),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Green Post Assessment button pinned under the topic list. Completing it is
/// what finishes the module and opens the next one.
class _PostAssessmentBar extends ConsumerWidget {
  final int moduleId;
  final String moduleName;

  const _PostAssessmentBar({
    required this.moduleId,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppGloss.radiusSm),
            boxShadow: [
              BoxShadow(
                color: AppColors.assessmentAction.withValues(alpha: 0.40),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
              const BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppGloss.radiusSm),
            child: InkWell(
              onTap: () => context.push(
                AppRoutes.moduleAssessmentPath(moduleId),
                extra: moduleName,
              ),
              borderRadius: BorderRadius.circular(AppGloss.radiusSm),
              child: Container(
                height: AppButton.height,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF12B981), AppColors.assessmentAction],
                  ),
                  borderRadius: BorderRadius.circular(AppGloss.radiusSm),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AppGloss.sheen(r: AppGloss.radiusSm),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text('Post Assessment', style: AppText.button),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final int languageId;
  final Future<void> Function() onRetry;

  const _Message({
    required this.text,
    required this.languageId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(AppStrings.of('retry', languageId)),
            ),
          ],
        ),
      ),
    );
  }
}
