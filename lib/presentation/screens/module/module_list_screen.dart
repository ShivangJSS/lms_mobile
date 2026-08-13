import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/colors.dart';
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Women With Wheels'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModuleTypeTabs(
            categories: state.categories,
            selectedTypeId: state.selectedTypeId,
            onSelected: viewModel.selectType,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF8A6C8C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Module List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _ModuleListBody(
              onRefresh: viewModel.load,
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
