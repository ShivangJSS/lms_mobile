import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../domain/entities/learning_module.dart';
import '../../viewmodels/module_view_model.dart';

class ModuleListScreen extends ConsumerWidget {
  const ModuleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moduleViewModelProvider);
    final viewModel = ref.read(moduleViewModelProvider.notifier);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageWash),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: topInset),
            _SegmentedTypeTabs(
              categories: state.categories,
              selectedTypeId: state.selectedTypeId,
              onSelected: viewModel.selectType,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ModuleListHeaderBar(count: state.modules.length),
            ),
            if (state.modules.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _ProgressSummary(modules: state.modules),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _ModuleListBody(
                onRefresh: viewModel.load,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

/// Polished pill segmented control (Technical / Non Technical). A recessed
/// track holds the segments; the active one lifts as a glossy plum chip while
/// the rest read as flat plum-on-white labels.
class _SegmentedTypeTabs extends StatelessWidget {
  final List<ModuleCategory> categories;
  final int? selectedTypeId;
  final ValueChanged<int?> onSelected;

  const _SegmentedTypeTabs({
    required this.categories,
    required this.selectedTypeId,
    required this.onSelected,
  });

  static const double _pill = 26;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1E7F6), Color(0xFFE9DAF0)],
          ),
          borderRadius: BorderRadius.circular(_pill + 5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          boxShadow: const [
            // Soft inner recess: a tight dark rim plus a top highlight.
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 1,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            for (final category in categories)
              Expanded(
                child: _Segment(
                  label: category.moduleType,
                  isActive: selectedTypeId == category.moduleTypeId,
                  onTap: () => onSelected(category.moduleTypeId),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: isActive
          ? BoxDecoration(
              gradient: AppColors.buttonGloss,
              borderRadius: BorderRadius.circular(_SegmentedTypeTabs._pill),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            )
          : const BoxDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_SegmentedTypeTabs._pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_SegmentedTypeTabs._pill),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                AppGloss.sheen(r: _SegmentedTypeTabs._pill),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(
                    fontSize: 14.5,
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

/// Glossy plum gradient "Module List" bar with depth and a live count chip.
class _ModuleListHeaderBar extends StatelessWidget {
  final int count;

  const _ModuleListHeaderBar({required this.count});

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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Module List', style: AppText.headingOnColor),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: AppText.label.copyWith(
                        color: Colors.white,
                        fontSize: 13,
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

/// A compact "your progress" banner summarising how many modules are done.
class _ProgressSummary extends StatelessWidget {
  final List<LearningModule> modules;

  const _ProgressSummary({required this.modules});

  @override
  Widget build(BuildContext context) {
    final total = modules.length;
    final done =
        modules.where((m) => m.status == ModuleStatus.completed).length;
    final pct = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppGloss.card(r: AppGloss.radius, shadow: AppGloss.soft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Progress',
                  style: AppText.label.copyWith(color: AppColors.primaryDark),
                ),
              ),
              Text(
                '$done / $total completed',
                style: AppText.muted.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: pct.clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: AppColors.buttonGloss,
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

class _ModuleListBody extends ConsumerWidget {
  final Future<void> Function() onRefresh;

  const _ModuleListBody({required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moduleViewModelProvider);

    if (state.isLoading && state.modules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _Message(
        text: state.error!,
        onRetry: onRefresh,
      );
    }

    if (state.modules.isEmpty) {
      return _Message(
        text: 'No modules have been assigned to you yet.',
        onRetry: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        itemCount: state.modules.length,
        itemBuilder: (context, index) {
          final module = state.modules[index];

          return _ModuleTile(
            module: module,
            onTap: () => context.push(
              AppRoutes.moduleDetailPath(module.moduleId),
              extra: module.moduleName,
            ),
          );
        },
      ),
    );
  }
}

/// Single module row rendered as a raised white glossy card. Locked modules
/// are not tappable and read as a muted, flat tile.
class _ModuleTile extends StatelessWidget {
  final LearningModule module;
  final VoidCallback? onTap;

  const _ModuleTile({required this.module, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = module.isLocked;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: locked
          ? AppGloss.panel(r: AppGloss.radius)
          : AppGloss.card(r: AppGloss.radius, shadow: AppGloss.soft),
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
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 8),
                      _StatusTag(status: module.status),
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: locked ? null : AppColors.brandGradientRich,
        color: locked ? AppColors.tintedPanel : null,
        borderRadius: BorderRadius.circular(AppGloss.radiusSm + 2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: locked
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Stack(
        children: [
          if (!locked) AppGloss.sheen(r: AppGloss.radiusSm + 2),
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

/// A small pill labelling the module state under the title.
class _StatusTag extends StatelessWidget {
  final ModuleStatus status;

  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    late final IconData icon;

    switch (status) {
      case ModuleStatus.completed:
        label = 'Completed';
        color = const Color(0xFF4E8B1C);
        icon = Icons.check_circle_rounded;
        break;
      case ModuleStatus.active:
        label = 'Continue';
        color = AppColors.primary;
        icon = Icons.play_circle_fill_rounded;
        break;
      case ModuleStatus.locked:
        label = 'Locked';
        color = AppColors.textSecondary;
        icon = Icons.lock_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Trailing status marker: green check (done), plum gradient chevron (next),
/// or a de-emphasised lock (locked).
class _StatusIcon extends StatelessWidget {
  final ModuleStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ModuleStatus.completed:
        return Container(
          width: 34,
          height: 34,
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
          width: 34,
          height: 34,
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
          width: 34,
          height: 34,
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

class _Message extends StatelessWidget {
  final String text;
  final Future<void> Function() onRetry;

  const _Message({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.muted,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
