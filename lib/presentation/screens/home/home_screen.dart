import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/colors.dart';
import '../../viewmodels/dashboard_view_model.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/login_view_model.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/dashboard_stats_card.dart';
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.of('dashboard', lang)),
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
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primary),
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
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _WelcomeCard(userName: userName, languageId: lang),
                      const SizedBox(height: 20),
                      if (dashboardState.stats != null) ...[
                        Row(
                          children: [
                            DashboardStatsCard(
                              title: AppStrings.of('modules_completed', lang),
                              value:
                                  '${dashboardState.stats!.modulesCompleted}/'
                                  '${dashboardState.stats!.totalModules}',
                              backgroundColor: AppColors.dashboardCard1,
                            ),
                            const SizedBox(width: 12),
                            DashboardStatsCard(
                              title: AppStrings.of('average_score', lang),
                              value: dashboardState.stats!.hasAttempts
                                  ? '${dashboardState.stats!.averageScore.round()}%'
                                  : '-',
                              backgroundColor: AppColors.dashboardCard2,
                            ),
                            const SizedBox(width: 12),
                            DashboardStatsCard(
                              title: AppStrings.of('time_invested', lang),
                              value:
                                  '${dashboardState.stats!.timeInvestedMinutes} min',
                              backgroundColor: AppColors.dashboardCard3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ProgressCard(
                          progress: dashboardState.stats!.overallProgress,
                          progressText:
                              '${(dashboardState.stats!.overallProgress * 100).round()}%',
                          message: AppStrings.of('keep_going', lang),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _PrimaryAction(
                        label: AppStrings.of('start_journey', lang),
                        onTap: () => context.push(AppRoutes.modules),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => context.push(AppRoutes.modules),
                          child: Text(
                            AppStrings.of('view_all_modules', lang),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.of('unlock_note', lang),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (final tip in dashboardState.tips) ...[
                        DidYouKnowCard(tip: tip, languageId: lang),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: navIndex,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF8A6C8C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.of('welcome', languageId)} $userName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.of('welcome_subtitle', languageId),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF8A6C8C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
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
