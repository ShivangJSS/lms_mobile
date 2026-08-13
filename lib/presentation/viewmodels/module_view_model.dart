import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../../domain/entities/learning_module.dart';
import 'language_view_model.dart';

class ModuleListState {
  final bool isLoading;
  final String? error;

  final List<LearningModule> modules;
  final List<ModuleCategory> categories;

  /// module_type_id currently filtered on, or null for all types.
  final int? selectedTypeId;

  final int languageId;

  const ModuleListState({
    required this.languageId,
    this.isLoading = false,
    this.error,
    this.modules = const [],
    this.categories = const [],
    this.selectedTypeId,
  });

  int get completedCount =>
      modules.where((module) => module.isCompleted).length;

  ModuleListState copyWith({
    bool? isLoading,
    String? error,
    List<LearningModule>? modules,
    List<ModuleCategory>? categories,
    int? selectedTypeId,
  }) {
    return ModuleListState(
      languageId: languageId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      modules: modules ?? this.modules,
      categories: categories ?? this.categories,
      selectedTypeId: selectedTypeId ?? this.selectedTypeId,
    );
  }
}

class ModuleViewModel extends StateNotifier<ModuleListState> {
  final Ref ref;

  ModuleViewModel(this.ref)
      : super(
          ModuleListState(
            languageId: ref.read(languageProvider).languageId,
          ),
        ) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(moduleRepositoryProvider);

      final categories = state.categories.isNotEmpty
          ? state.categories
          : await repository.getModuleTypes();

      final modules = await repository.getModules(
        languageId: state.languageId,
        moduleType: state.selectedTypeId,
      );

      state = state.copyWith(
        isLoading: false,
        modules: modules,
        categories: categories,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFor(e),
      );
    } on SocketException {
      state = state.copyWith(
        isLoading: false,
        error: "No internet connection",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectType(int? moduleTypeId) async {
    if (state.selectedTypeId == moduleTypeId) return;

    // Rebuilt rather than copied, because copyWith cannot set a null filter.
    state = ModuleListState(
      languageId: state.languageId,
      isLoading: true,
      modules: state.modules,
      categories: state.categories,
      selectedTypeId: moduleTypeId,
    );

    await load();
  }

  String _messageFor(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return "Your session has expired. Please log in again.";

      case 500:
        return "Server error. Please try again.";

      default:
        return e.message ?? "Could not load your modules";
    }
  }
}

final moduleViewModelProvider =
    StateNotifierProvider<ModuleViewModel, ModuleListState>(
  (ref) => ModuleViewModel(ref),
);
