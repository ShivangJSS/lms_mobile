import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../domain/entities/video_question.dart';

/// Talks to the activity-logging endpoints. The participant is taken from the
/// bearer token on the server, so nothing here sends a participant id.
class ActivityRemoteDataSource {
  final Dio _dio = ApiClient.dio;

  /// POST /mobile/module/activity/time-spent — whole-session minutes.
  Future<void> logTimeSpent(int minutes) async {
    await _dio.post(
      ApiConstants.timeSpent,
      data: {'time_spent_in_minutes': minutes},
    );
  }

  /// POST /mobile/module/activity/module-time — seconds on one document.
  Future<void> logModuleTime({
    required int moduleId,
    int? topicId,
    int? documentId,
    required int seconds,
  }) async {
    await _dio.post(
      ApiConstants.moduleTime,
      data: {
        'module_id': moduleId,
        if (topicId != null) 'topic_id': topicId,
        if (documentId != null) 'document_id': documentId,
        'time_taken': seconds,
      },
    );
  }

  /// GET /mobile/module/activity/video-questions/{video_id}
  Future<List<VideoQuizQuestion>> getVideoQuestions({
    required int videoId,
    required int languageId,
  }) async {
    final response = await _dio.get(
      ApiConstants.videoQuestions(videoId),
      queryParameters: {'language_id': languageId},
    );

    return ((response.data as List<dynamic>?) ?? [])
        .map((e) => VideoQuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /mobile/module/activity/video-question — one row per answer.
  Future<int> submitVideoAnswers({
    required int videoId,
    required int topicId,
    required int moduleId,
    required Map<int, int> answers,
  }) async {
    final response = await _dio.post(
      ApiConstants.videoQuestionSubmit,
      data: {
        'video_id': videoId,
        'topic_id': topicId,
        'module_id': moduleId,
        'answers': answers.entries
            .map((e) => {'question_id': e.key, 'option_id': e.value})
            .toList(),
      },
    );

    final data = response.data;
    if (data is Map && data['total_answers'] is num) {
      return (data['total_answers'] as num).toInt();
    }
    return answers.length;
  }
}
