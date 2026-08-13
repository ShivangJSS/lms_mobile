import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../../domain/entities/feedback_question.dart';
import 'language_view_model.dart';

class FeedbackState {
  final bool isLoading;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? error;

  final List<FeedbackQuestion> questions;

  /// The longer questionnaire opened from the side navigation.
  final List<FeedbackFormField> formFields;

  /// question_id -> selected option ids.
  final Map<int, List<int>> answers;

  /// participant_feedback column -> String, or List<String> when multi-select.
  final Map<String, dynamic> formAnswers;

  const FeedbackState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.error,
    this.questions = const [],
    this.formFields = const [],
    this.answers = const {},
    this.formAnswers = const {},
  });

  /// Post-sign-in mood check: every mood question must be answered.
  bool get canSubmitMood =>
      questions.isNotEmpty &&
      questions.every(
        (question) => (answers[question.questionId] ?? const []).isNotEmpty,
      );

  /// The longer questionnaire is optional, so one answer is enough to send.
  bool get canSubmitForm => formAnswers.isNotEmpty;

  FeedbackState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isSubmitted,
    String? error,
    List<FeedbackQuestion>? questions,
    List<FeedbackFormField>? formFields,
    Map<int, List<int>>? answers,
    Map<String, dynamic>? formAnswers,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      error: error,
      questions: questions ?? this.questions,
      formFields: formFields ?? this.formFields,
      answers: answers ?? this.answers,
      formAnswers: formAnswers ?? this.formAnswers,
    );
  }
}

class FeedbackViewModel extends StateNotifier<FeedbackState> {
  final Ref ref;

  FeedbackViewModel(this.ref) : super(const FeedbackState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(feedbackRepositoryProvider);

      final questions = await repository.getQuestions(
        languageId: ref.read(languageProvider).languageId,
      );

      // The longer questionnaire is optional — if it fails the mood
      // questions are still usable.
      List<FeedbackFormField> formFields = const [];

      try {
        formFields = await repository.getForm();
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        questions: questions,
        formFields: formFields,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFor(e));
    }
  }

  /// Single-choice or free-text answer in the longer questionnaire.
  void setFormAnswer(String field, String value) {
    final answers = Map<String, dynamic>.from(state.formAnswers);

    if (value.isEmpty) {
      answers.remove(field);
    } else {
      answers[field] = value;
    }

    state = state.copyWith(formAnswers: answers);
  }

  void toggleFormOption(String field, String value) {
    final answers = Map<String, dynamic>.from(state.formAnswers);

    final selected = List<String>.from(
      (answers[field] as List?)?.cast<String>() ?? const [],
    );

    if (selected.contains(value)) {
      selected.remove(value);
    } else {
      selected.add(value);
    }

    if (selected.isEmpty) {
      answers.remove(field);
    } else {
      answers[field] = selected;
    }

    state = state.copyWith(formAnswers: answers);
  }

  String? formValue(String field) {
    final value = state.formAnswers[field];
    return value is String ? value : null;
  }

  bool isFormOptionSelected(String field, String value) {
    final current = state.formAnswers[field];

    if (current is List) return current.contains(value);

    return current == value;
  }

  /// Replaces the answer for a single-choice question.
  void selectSingle(int questionId, int optionId) {
    final answers = Map<int, List<int>>.from(state.answers);

    answers[questionId] = [optionId];

    state = state.copyWith(answers: answers);
  }

  /// Adds or removes one option of a multi-choice question.
  void toggleMultiple(int questionId, int optionId) {
    final answers = Map<int, List<int>>.from(state.answers);

    final selected = List<int>.from(answers[questionId] ?? const []);

    if (selected.contains(optionId)) {
      selected.remove(optionId);
    } else {
      selected.add(optionId);
    }

    answers[questionId] = selected;

    state = state.copyWith(answers: answers);
  }

  bool isSelected(int questionId, int optionId) =>
      (state.answers[questionId] ?? const []).contains(optionId);

  Future<void> submit() async {
    if (state.isSubmitting) return;

    if (!state.canSubmitMood && !state.canSubmitForm) return;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      await ref.read(feedbackRepositoryProvider).submit(
            usefulModules: const [],
            moodAnswers: state.answers,
            formAnswers: state.formAnswers,
          );

      // Answers are cleared once stored, so reopening the form starts fresh
      // rather than showing what was already submitted.
      state = FeedbackState(
        isSubmitted: true,
        questions: state.questions,
        formFields: state.formFields,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: _messageFor(e));
    }
  }

  String _messageFor(Object e) {
    if (e is DioException) {
      switch (e.response?.statusCode) {
        case 400:
          return e.response?.data?['detail']?.toString() ??
              "Please check your answers.";
        case 401:
          return "Your session has expired. Please log in again.";
        case 500:
          return "Server error. Please try again.";
        default:
          return e.message ?? "Something went wrong";
      }
    }

    if (e is SocketException) return "No internet connection";

    return e.toString();
  }
}

final feedbackViewModelProvider =
    StateNotifierProvider<FeedbackViewModel, FeedbackState>(
  (ref) => FeedbackViewModel(ref),
);
