import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/providers.dart';
import '../../domain/entities/feedback_question.dart';

class AssessmentState {
  final bool isLoading;
  final String? error;
  final List<FeedbackQuestion>? questions;
  final Map<String, String> answers;
  final bool isSubmitting;
  final bool isSubmitted;

  AssessmentState({
    this.isLoading = false,
    this.error,
    this.questions,
    this.answers = const {},
    this.isSubmitting = false,
    this.isSubmitted = false,
  });

  AssessmentState copyWith({
    bool? isLoading,
    String? error,
    List<FeedbackQuestion>? questions,
    Map<String, String>? answers,
    bool? isSubmitting,
    bool? isSubmitted,
  }) {
    return AssessmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class AssessmentViewModel extends StateNotifier<AssessmentState> {
  final Ref ref;

  AssessmentViewModel(this.ref) : super(AssessmentState()) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(assessmentRepositoryProvider);
      final questions = await repository.getFeedbackQuestions();
      state = state.copyWith(isLoading: false, questions: questions);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void answerQuestion(String questionId, String answer) {
    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[questionId] = answer;
    state = state.copyWith(answers: newAnswers);
  }

  bool canSubmit() {
    if (state.questions == null) return false;
    return state.answers.length == state.questions!.length;
  }

  Future<void> submit() async {
    if (!canSubmit()) return;
    
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final repository = ref.read(assessmentRepositoryProvider);
      final success = await repository.submitFeedback(state.answers);
      state = state.copyWith(isSubmitting: false, isSubmitted: success);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}

final assessmentViewModelProvider = StateNotifierProvider<AssessmentViewModel, AssessmentState>((ref) {
  return AssessmentViewModel(ref);
});
