import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/feedback_question_model.dart';

class FeedbackRemoteDataSource {
  final Dio _dio = ApiClient.dio;

  /// GET /mobile/feedback/questions
  Future<List<FeedbackQuestionModel>> getQuestions({
    required int languageId,
  }) async {
    final response = await _dio.get(
      ApiConstants.feedbackQuestions,
      queryParameters: {'language_id': languageId},
    );

    final questions = response.data as List<dynamic>? ?? [];

    return questions
        .map(
          (item) => FeedbackQuestionModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// GET /mobile/feedback/form — the full trainee questionnaire.
  Future<List<FeedbackFormFieldModel>> getForm() async {
    final response = await _dio.get(ApiConstants.feedbackForm);

    final fields = response.data as List<dynamic>? ?? [];

    return fields
        .map(
          (item) => FeedbackFormFieldModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// POST /mobile/feedback/submit
  ///
  /// The participant is taken from the bearer token, so it is not sent.
  Future<int> submit({
    String? lmsExperience,
    String? lmsEase,
    required List<String> usefulModules,
    required Map<int, List<int>> moodAnswers,
    Map<String, dynamic> formAnswers = const {},
  }) async {
    final response = await _dio.post(
      ApiConstants.feedbackSubmit,
      data: {
        'lms_experience': lmsExperience,
        'lms_ease': lmsEase,
        'useful_modules': usefulModules,
        'mood_answers': moodAnswers.entries
            .map(
              (entry) => {
                'question_id': entry.key,
                'selected_options': entry.value,
              },
            )
            .toList(),
        'form_answers': formAnswers,
      },
    );

    return response.data['feedback_id'] as int? ?? 0;
  }
}
