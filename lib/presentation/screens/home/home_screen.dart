import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../core/widgets/primary_button.dart';
import '../../viewmodels/dashboard_view_model.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/login_view_model.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/did_you_know_card.dart';
import '../../widgets/progress_card.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final loginState = ref.watch(loginViewModelProvider);
    final lang = ref.watch(languageProvider).languageId;
    final navIndex = ref.watch(bottomNavIndexProvider);

    final userName = loginState.user?.participantName ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.of('dashboard', lang)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradientRich,
                ),
              ),
            ),
            AppGloss.sheen(r: 0),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.profile),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: AppGloss.glass(r: 40, opacity: 0.20),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: AppColors.primary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
              ? _ErrorView(
                  message: dashboardState.error!,
                  languageId: lang,
                  onRetry: () => ref
                      .read(dashboardViewModelProvider.notifier)
                      .loadDashboard(),
                )
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(dashboardViewModelProvider.notifier)
                      .loadDashboard(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
                    children: [
                      _WelcomeCard(userName: userName, languageId: lang),
                      const SizedBox(height: AppSpacing.md),
                      if (dashboardState.stats != null) ...[
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _StatTile(
                                title:
                                    AppStrings.of('modules_completed', lang),
                                value:
                                    '${dashboardState.stats!.modulesCompleted}/'
                                    '${dashboardState.stats!.totalModules}',
                                icon: Icons.check_circle_outline,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _StatTile(
                                title: AppStrings.of('average_score', lang),
                                value: dashboardState.stats!.hasAttempts
                                    ? '${dashboardState.stats!.averageScore.round()}%'
                                    : '-',
                                icon: Icons.emoji_events_outlined,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _StatTile(
                                title: AppStrings.of('time_invested', lang),
                                value:
                                    '${dashboardState.stats!.timeInvestedMinutes} min',
                                icon: Icons.schedule_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ProgressCard(
                          progress: dashboardState.stats!.overallProgress,
                          progressText:
                              '${(dashboardState.stats!.overallProgress * 100).round()}%',
                          message: AppStrings.of('keep_going', lang),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        text: AppStrings.of('start_journey', lang),
                        trailingIcon: Icons.arrow_forward_rounded,
                        onPressed: () => context.push(AppRoutes.modules),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppGloss.radiusSm),
                          child: InkWell(
                            onTap: () => context.push(AppRoutes.modules),
                            borderRadius:
                                BorderRadius.circular(AppGloss.radiusSm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: AppGloss.panel(
                                color: AppColors.dashboardCard1,
                                r: AppGloss.radiusSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppStrings.of('view_all_modules', lang),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppStrings.of('unlock_note', lang),
                        style: AppText.caption.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final tip in dashboardState.tips) ...[
                        DidYouKnowCard(tip: tip, languageId: lang),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradientRich,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x336A1B9A),
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: navIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500),
            onTap: (index) {
              ref.read(bottomNavIndexProvider.notifier).state = index;
              if (index == 1) context.push(AppRoutes.modules);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: 'Module',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.support),
                label: 'Support',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.help_outline),
                label: 'FAQ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String userName;
  final int languageId;

  const _WelcomeCard({required this.userName, required this.languageId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientRich,
        borderRadius: BorderRadius.circular(AppGloss.radiusLg),
        boxShadow: AppGloss.lifted,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Soft decorative circles bleeding off the edges for depth.
          Positioned(top: -34, right: -26, child: _circle(130)),
          Positioned(bottom: -46, left: -30, child: _circle(120)),
          AppGloss.sheen(r: AppGloss.radiusLg),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Frosted glass avatar badge.
                Container(
                  height: 54,
                  width: 54,
                  alignment: Alignment.center,
                  decoration: AppGloss.glass(r: 40, opacity: 0.22),
                  child: const Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.of('welcome', languageId)} $userName',
                        style: AppText.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppStrings.of('welcome_subtitle', languageId),
                        style: AppText.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circle(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}

/// Raised white glossy stat tile: a plum-tinted circular icon badge over a
/// bold value and a muted caption. Sits in the dashboard's three-up row.
class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: AppGloss.card(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 46,
              width: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.primary.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final int languageId;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
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
              message,
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
