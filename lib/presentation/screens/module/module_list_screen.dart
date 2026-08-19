import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../viewmodels/module_view_model.dart';
import '../../widgets/module_card.dart';
import '../../widgets/module_type_tabs.dart';

class ModuleListScreen extends ConsumerWidget {
  const ModuleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moduleViewModelProvider);
    final viewModel = ref.read(moduleViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Women With Wheels'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.brandGradientRich),
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
            ModuleTypeTabs(
              categories: state.categories,
              selectedTypeId: state.selectedTypeId,
              onSelected: viewModel.selectType,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradientRich,
                  borderRadius: BorderRadius.circular(AppGloss.radius),
                  boxShadow: AppGloss.soft,
                ),
                child: Stack(
                  children: [
                    AppGloss.sheen(r: AppGloss.radius),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Text('Module List',
                          style: AppText.headingOnColor),
                    ),
                  ],
                ),
              ),
            ),
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
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
        itemCount: state.modules.length,
        itemBuilder: (context, index) {
          final module = state.modules[index];

          return ModuleCard(
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
