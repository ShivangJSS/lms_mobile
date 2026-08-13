import '../../domain/entities/feedback_question.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasource/remote/feedback_remote_datasource.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource dataSource;

  FeedbackRepositoryImpl(this.dataSource);

  @override
  Future<List<FeedbackQuestion>> getQuestions({
    required int languageId,
  }) async {
    return await dataSource.getQuestions(languageId: languageId);
  }

  @override
  Future<List<FeedbackFormField>> getForm() async {
    return await dataSource.getForm();
  }

  @override
  Future<int> submit({
    String? lmsExperience,
    String? lmsEase,
    required List<String> usefulModules,
    required Map<int, List<int>> moodAnswers,
    Map<String, dynamic> formAnswers = const {},
  }) async {
    return await dataSource.submit(
      lmsExperience: lmsExperience,
      lmsEase: lmsEase,
      usefulModules: usefulModules,
      moodAnswers: moodAnswers,
      formAnswers: formAnswers,
    );
  }
}
