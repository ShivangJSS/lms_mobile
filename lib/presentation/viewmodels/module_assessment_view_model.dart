import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../../domain/entities/assessment_answer.dart';
import '../../domain/entities/module_assessment.dart';
import 'language_view_model.dart';

class ModuleAssessmentState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  final ModuleAssessment? assessment;

  /// Keyed by question.key so ids from different banks cannot collide.
  final Map<String, AssessmentAnswer> answers;

  final AssessmentResult? result;

  /// -1 is the instructions page; 0 onwards are the questions.
  final int pageIndex;

  const ModuleAssessmentState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.assessment,
    this.answers = const {},
    this.result,
    this.pageIndex = -1,
  });

  bool get onInstructions => pageIndex < 0;

  bool get onLastQuestion => pageIndex == questions.length - 1;

  AssessmentQuestionItem? get currentQuestion =>
      pageIndex >= 0 && pageIndex < questions.length
          ? questions[pageIndex]
          : null;

  /// The visible question must be answered before moving on.
  bool get canAdvance {
    final question = currentQuestion;

    if (question == null) return true;

    return answers[question.key]?.isAnswered == true;
  }

  List<AssessmentQuestionItem> get questions =>
      assessment?.questions ?? const [];

  bool get canSubmit =>
      questions.isNotEmpty &&
      questions.every((q) => answers[q.key]?.isAnswered == true);

  int get answeredCount =>
      questions.where((q) => answers[q.key]?.isAnswered == true).length;

  ModuleAssessmentState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    ModuleAssessment? assessment,
    Map<String, AssessmentAnswer>? answers,
    AssessmentResult? result,
    int? pageIndex,
  }) {
    return ModuleAssessmentState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      assessment: assessment ?? this.assessment,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      pageIndex: pageIndex ?? this.pageIndex,
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

  // Future<void> load() async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   try {
  //     final assessment =
  //         await ref.read(moduleAssessmentRepositoryProvider).getAssessment(
  //               moduleId: moduleId,
  //               languageId: ref.read(languageProvider).languageId,
  //             );
  //
  //     state = ModuleAssessmentState(assessment: assessment);
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: _messageFor(e));
  //   }
  // }

  // Future<void> load() async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   try {
  //     final assessment =
  //         await ref.read(moduleAssessmentRepositoryProvider).getAssessment(
  //               moduleId: moduleId,
  //               languageId: ref.read(languageProvider).languageId,
  //             );
  //
  //     // FIX: Use copyWith to keep existing pageIndex and answers
  //     // while only updating the assessment content (translations).
  //     state = state.copyWith(
  //       isLoading: false,
  //       assessment: assessment,
  //     );
  //
  //     // Safety check: if current page is now beyond the new question list
  //     // (e.g. if a language has fewer questions), reset to the last page.
  //     if (state.pageIndex >= assessment.questions.length) {
  //       state = state.copyWith(
  //         pageIndex: assessment.questions.length - 1,
  //       );
  //     }
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: _messageFor(e));
  //   }
  // }

  // lib/presentation/viewmodels/module_assessment_view_model.dart

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final assessment =
          await ref.read(moduleAssessmentRepositoryProvider).getAssessment(
                moduleId: moduleId,
                languageId: ref.read(languageProvider).languageId,
              );

      // Use copyWith to keep existing pageIndex and answers
      // while updating questions and potentially the result.
      state = state.copyWith(
        isLoading: false,
        assessment: assessment,
        // Update result if the server provides it, otherwise keep current state
        result: assessment.result ?? state.result,
      );

      // Safety check: preserve current page unless it's out of bounds
      if (state.pageIndex >= assessment.questions.length) {
        state = state.copyWith(
          pageIndex: assessment.questions.length - 1,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFor(e));
    }
  }

  AssessmentAnswer _answerFor(AssessmentQuestionItem question) =>
      state.answers[question.key] ??
      AssessmentAnswer(type: question.type, questionId: question.questionId);

  void _put(AssessmentQuestionItem question, AssessmentAnswer answer) {
    final answers = Map<String, AssessmentAnswer>.from(state.answers);

    answers[question.key] = answer;

    state = state.copyWith(answers: answers);
  }

  // ---------------- MCQ / SCQ ----------------

  void selectOption(AssessmentQuestionItem question, int optionId) {
    final current = _answerFor(question);

    List<int> selected;

    if (!question.allowsMultiple) {
      selected = [optionId];
    } else {
      selected = List<int>.from(current.selectedOptions);

      if (selected.contains(optionId)) {
        selected.remove(optionId);
      } else {
        selected.add(optionId);
      }
    }

    _put(question, current.copyWith(selectedOptions: selected));
  }

  bool isOptionSelected(AssessmentQuestionItem question, int optionId) =>
      state.answers[question.key]?.selectedOptions.contains(optionId) ?? false;

  // ---------------- Drop bucket ----------------

  void placeItem(
    AssessmentQuestionItem question,
    int itemId,
    int bucketId,
  ) {
    final current = _answerFor(question);

    final placements = Map<int, int>.from(current.placements);

    placements[itemId] = bucketId;

    _put(question, current.copyWith(placements: placements));
  }

  /// Empties every bucket for this question — the Reset link.
  void resetPlacements(AssessmentQuestionItem question) {
    _put(question, _answerFor(question).copyWith(placements: const {}));
  }

  void removeItem(AssessmentQuestionItem question, int itemId) {
    final current = _answerFor(question);

    final placements = Map<int, int>.from(current.placements)..remove(itemId);

    _put(question, current.copyWith(placements: placements));
  }

  int? bucketOf(AssessmentQuestionItem question, int itemId) =>
      state.answers[question.key]?.placements[itemId];

  // ---------------- Match making ----------------

  void pair(AssessmentQuestionItem question, int leftId, int rightId) {
    final current = _answerFor(question);

    final pairs = Map<int, int>.from(current.pairs);

    // A right item can only be used once, so any earlier use is released.
    pairs.removeWhere((_, value) => value == rightId);

    pairs[leftId] = rightId;

    _put(question, current.copyWith(pairs: pairs));
  }

  void unpair(AssessmentQuestionItem question, int leftId) {
    final current = _answerFor(question);

    final pairs = Map<int, int>.from(current.pairs)..remove(leftId);

    _put(question, current.copyWith(pairs: pairs));
  }

  int? matchOf(AssessmentQuestionItem question, int leftId) =>
      state.answers[question.key]?.pairs[leftId];

  // ---------------- submit ----------------

  Future<void> submit() async {
    if (!state.canSubmit || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final result = await ref.read(moduleAssessmentRepositoryProvider).submit(
            moduleId: moduleId,
            languageId: ref.read(languageProvider).languageId,
            answers: state.answers.values.toList(),
          );

      state = state.copyWith(isSubmitting: false, result: result);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: _messageFor(e));
    }
  }

  // ---------------- paging ----------------

  void next() {
    if (state.onLastQuestion) return;

    state = state.copyWith(pageIndex: state.pageIndex + 1);
  }

  void previous() {
    if (state.pageIndex <= 0) return;

    state = state.copyWith(pageIndex: state.pageIndex - 1);
  }

  /// Clears the previous attempt so the participant can retry from the start.
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

// final moduleAssessmentViewModelProvider = StateNotifierProvider.family<
//     ModuleAssessmentViewModel, ModuleAssessmentState, int>(
//   (ref, moduleId) => ModuleAssessmentViewModel(ref, moduleId),
// );

// final moduleAssessmentViewModelProvider = StateNotifierProvider.autoDispose
//     .family<ModuleAssessmentViewModel, ModuleAssessmentState, int>(
//   (ref, moduleId) {
//     // This line ensures it reloads when language changes too
//     ref.watch(languageProvider);
//     return ModuleAssessmentViewModel(ref, moduleId);
//   },
// );

// final moduleAssessmentViewModelProvider = StateNotifierProvider.autoDispose
//     .family<ModuleAssessmentViewModel, ModuleAssessmentState, int>(
//   (ref, moduleId) {
//     final viewModel = ModuleAssessmentViewModel(ref, moduleId);
//
//     // This replaces ref.watch. It still reloads the data (fixing the cache issue)
//     // but it allows the ViewModel to keep your current page and answers.
//     ref.listen(languageProvider, (previous, next) {
//       if (previous?.languageId != next.languageId) {
//         viewModel.load();
//       }
//     });
//
//     return viewModel;
//   },
// );

// lib/presentation/viewmodels/module_assessment_view_model.dart

final moduleAssessmentViewModelProvider = StateNotifierProvider.autoDispose
    .family<ModuleAssessmentViewModel, ModuleAssessmentState, int>(
  (ref, moduleId) {
    final viewModel = ModuleAssessmentViewModel(ref, moduleId);

    // Listen for language changes and trigger a reload of questions
    // without destroying the current viewModel instance (preserving answers/pageIndex).
    ref.listen(languageProvider, (previous, next) {
      if (previous?.languageId != next.languageId) {
        viewModel.load();
      }
    });

    return viewModel;
  },
);

// lib/presentation/viewmodels/module_assessment_view_model.dart

// Change this: Remove .autoDispose
// final moduleAssessmentViewModelProvider = StateNotifierProvider.family<
//     ModuleAssessmentViewModel, ModuleAssessmentState, int>(
//   (ref, moduleId) {
//     final viewModel = ModuleAssessmentViewModel(ref, moduleId);
//
//     // This ensures that when you change language, the questions are re-fetched
//     // but the ViewModel instance (and thus your pageIndex/answers) stays the same.
//     ref.listen(languageProvider, (previous, next) {
//       if (previous?.languageId != next.languageId) {
//         viewModel.load();
//       }
//     });
//
//     return viewModel;
//   },
// );
