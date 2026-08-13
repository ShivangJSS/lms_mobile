import '../../../data/models/assessment_question_model.dart';

/// PLACEHOLDER DATA.
///
/// The assessment screen has no backend yet — there is no mobile assessment
/// endpoint. The dashboard, module and feedback screens all run on the real
/// API now; this is the last remaining stub. Delete this file and its
/// provider once /mobile/assessment exists.
class DummyAssessmentDataSource {
  Future<List<AssessmentQuestionModel>> getAssessmentQuestions() async {
    await Future.delayed(const Duration(seconds: 1));

    return const [
      AssessmentQuestionModel(
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
      AssessmentQuestionModel(
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

  Future<bool> submitAssessment(Map<String, dynamic> answers) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
