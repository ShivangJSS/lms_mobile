import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../../domain/entities/module_assessment.dart';
import 'language_view_model.dart';

class ModuleAssessmentState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  final ModuleAssessment? assessment;

  /// mcq_id -> selected option ids.
  final Map<int, List<int>> answers;

  final AssessmentResult? result;

  const ModuleAssessmentState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.assessment,
    this.answers = const {},
    this.result,
  });

  bool get canSubmit {
    final questions = assessment?.questions ?? const [];

    return questions.isNotEmpty &&
        questions.every(
          (question) => (answers[question.mcqId] ?? const []).isNotEmpty,
        );
  }

  ModuleAssessmentState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    ModuleAssessment? assessment,
    Map<int, List<int>>? answers,
    AssessmentResult? result,
  }) {
    return ModuleAssessmentState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      assessment: assessment ?? this.assessment,
      answers: answers ?? this.answers,
      result: result ?? this.result,
    );
  }
}

class ModuleAssessmentViewModel extends StateNotifier<ModuleAssessmentState> {
  final Ref ref;
  final int moduleId;

  ModuleAssessmentViewModel(this.ref, this.moduleId)
      : super(const ModuleAssessmentState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final assessment =
          await ref.read(moduleAssessmentRepositoryProvider).getAssessment(
                moduleId: moduleId,
                languageId: ref.read(languageProvider).languageId,
              );

      state = ModuleAssessmentState(assessment: assessment);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFor(e));
    }
  }

  void select(McqQuestion question, int optionId) {
    final answers = Map<int, List<int>>.from(state.answers);

    if (!question.allowsMultiple) {
      answers[question.mcqId] = [optionId];
    } else {
      final selected = List<int>.from(answers[question.mcqId] ?? const []);

      if (selected.contains(optionId)) {
        selected.remove(optionId);
      } else {
        selected.add(optionId);
      }

      answers[question.mcqId] = selected;
    }

    state = state.copyWith(answers: answers);
  }

  bool isSelected(int mcqId, int optionId) =>
      (state.answers[mcqId] ?? const []).contains(optionId);

  Future<void> submit() async {
    if (!state.canSubmit || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final result =
          await ref.read(moduleAssessmentRepositoryProvider).submit(
                moduleId: moduleId,
                answers: state.answers,
              );

      state = state.copyWith(isSubmitting: false, result: result);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: _messageFor(e));
    }
  }

  /// Clears the previous attempt so the participant can retry.
  void retry() {
    state = ModuleAssessmentState(assessment: state.assessment);
  }

  String _messageFor(Object e) {
    if (e is DioException) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']?.toString()
          : null;

      switch (e.response?.statusCode) {
        case 400:
          return detail ?? 'Please check your answers.';
        case 401:
          return 'Your session has expired. Please log in again.';
        case 403:
          return detail ?? 'This module is not open yet.';
        case 404:
          return 'This module has no assessment yet.';
        default:
          return e.message ?? 'Something went wrong';
      }
    }

    if (e is SocketException) return 'No internet connection';

    return e.toString();
  }
}

final moduleAssessmentViewModelProvider = StateNotifierProvider.family<
    ModuleAssessmentViewModel, ModuleAssessmentState, int>(
  (ref, moduleId) => ModuleAssessmentViewModel(ref, moduleId),
);
