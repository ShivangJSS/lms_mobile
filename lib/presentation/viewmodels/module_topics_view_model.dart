import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../../domain/entities/learning_module.dart';
import 'language_view_model.dart';

class ModuleTopicsState {
  final bool isLoading;
  final String? error;
  final List<ModuleTopic> topics;

  /// The module's own content, shown above the topic list.
  final ModuleOverviewInfo? overview;

  const ModuleTopicsState({
    this.isLoading = false,
    this.error,
    this.topics = const [],
    this.overview,
  });

  ModuleTopicsState copyWith({
    bool? isLoading,
    String? error,
    List<ModuleTopic>? topics,
    ModuleOverviewInfo? overview,
  }) {
    return ModuleTopicsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      topics: topics ?? this.topics,
      overview: overview ?? this.overview,
    );
  }
}

class ModuleTopicsViewModel extends StateNotifier<ModuleTopicsState> {
  final Ref ref;
  final int moduleId;

  ModuleTopicsViewModel(this.ref, this.moduleId)
      : super(const ModuleTopicsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final content = await ref.read(moduleRepositoryProvider).getModuleTopics(
            moduleId: moduleId,
            languageId: ref.read(languageProvider).languageId,
          );

      state = state.copyWith(
        isLoading: false,
        topics: content.topics,
        overview: content.overview,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.statusCode == 404
            ? "This module has no content yet."
            : (e.message ?? "Could not load this module"),
      );
    } on SocketException {
      state = state.copyWith(
        isLoading: false,
        error: "No internet connection",
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Keyed by module id so each module keeps its own topic list.
final moduleTopicsViewModelProvider = StateNotifierProvider.family<
    ModuleTopicsViewModel, ModuleTopicsState, int>(
  (ref, moduleId) => ModuleTopicsViewModel(ref, moduleId),
);
