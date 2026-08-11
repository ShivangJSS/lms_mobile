import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/colors.dart';
import '../../viewmodels/dashboard_view_model.dart';
import '../../viewmodels/login_view_model.dart';
import '../../widgets/dashboard_stats_card.dart';
import '../../widgets/progress_card.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final loginState = ref.watch(loginViewModelProvider);
    final navIndex = ref.watch(bottomNavIndexProvider);

    final userName =
        loginState.user?.participantName ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.profile),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/images/user.png',
                  errorBuilder: (c, e, s) => const Icon(Icons.person, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primary, size: 40),
              ),
          accountName: Text(
            userName,
            style: const TextStyle(fontSize: 18),
          ),
              accountEmail: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  context.push(AppRoutes.profile);
                },
                child: const Text(
                  'View Profile',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Change Language'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.feedback);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                ref.read(loginViewModelProvider.notifier).logout();
                context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
              ? Center(child: Text(dashboardState.error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A6C8C), // Muted purple from screenshot
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome $userName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Continue your journey to becoming a confident driver',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stats Row
                      if (dashboardState.stats != null) ...[
                        Row(
                          children: [
                            DashboardStatsCard(
                              title: 'Module\nCompleted',
                              value: '${dashboardState.stats!.modulesCompleted}/${dashboardState.stats!.totalModules}',
                              backgroundColor: AppColors.dashboardCard1,
                            ),
                            const SizedBox(width: 12),
                            DashboardStatsCard(
                              title: 'Average\nScore',
                              value: '${dashboardState.stats!.averageScore.toInt()}%',
                              backgroundColor: AppColors.dashboardCard2,
                            ),
                            const SizedBox(width: 12),
                            DashboardStatsCard(
                              title: 'Time\nInvested',
                              value: '${dashboardState.stats!.timeInvestedMinutes} min',
                              backgroundColor: AppColors.dashboardCard3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Progress Card
                        ProgressCard(
                          progress: dashboardState.stats!.overallProgress,
                          progressText: '${(dashboardState.stats!.overallProgress * 100).toInt()}%',
                          message: 'Keep up the great work!',
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Start Journey Card
                      InkWell(
                        onTap: () {
                          context.push(AppRoutes.assessment);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8A6C8C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Start Your Learning Journey',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            context.push(AppRoutes.modules);
                          },
                          child: const Text(
                            'View All Modules',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Note: The topic will be unlocked once previous training completed.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
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
              if (index == 1) {
                context.push(AppRoutes.modules); 
              }
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
