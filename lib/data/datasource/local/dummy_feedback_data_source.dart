import '../../../data/models/feedback_question_model.dart';

class DummyFeedbackDataSource {
  Future<List<FeedbackQuestionModel>> getFeedbackQuestions() async {
    await Future.delayed(const Duration(seconds: 1));

    return const [
      FeedbackQuestionModel(
        id: 'q1',
        questionText: 'How are you feeling today?',
        questionType: 'single_choice',
        options: [
          '😀 Energized and ready to learn!',
          '🙂 Calm and curious.',
          '😐 Just getting through the day.',
          '😟 Not in my best mood right now.',
        ],
      ),
      FeedbackQuestionModel(
        id: 'q2',
        questionText: 'What brings you here?',
        questionType: 'multiple_choice',
        options: [
          'Learn new driving skills',
          'Prepare for employment',
          'Build confidence',
          'Personal growth',
        ],
      ),
    ];
  }

  Future<bool> submitFeedback(Map<String, dynamic> answers) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}