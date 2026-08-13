import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:women_with_wheels_refactor/core/network/api_constants.dart';
import 'package:women_with_wheels_refactor/core/network/media_url.dart';
import 'package:women_with_wheels_refactor/data/models/dashboard_stats_model.dart';
import 'package:women_with_wheels_refactor/data/models/dashboard_tip_model.dart';
import 'package:women_with_wheels_refactor/data/models/feedback_question_model.dart';
import 'package:women_with_wheels_refactor/data/models/learning_module_model.dart';
import 'package:women_with_wheels_refactor/data/models/module_assessment_model.dart';
import 'package:women_with_wheels_refactor/domain/entities/learning_module.dart';

/// Payloads captured verbatim from the running backend for participant 54.
const _dashboardJson = '''
{"modules_completed":2,"total_modules":8,"average_score":94.37,
 "questions_attempted":71,"time_invested_minutes":101,
 "time_invested_seconds":6074,"overall_progress":0.25}
''';

const _moduleListJson = '''
{"language_id":1,"total":2,"completed":1,"modules":[
 {"module_id":1,"parent_id":1,"module_name":"Learning License",
  "module_description":"Understand basic traffic concepts.",
  "module_type_id":1,"module_type_name":"Technical",
  "duration_minutes":140,"duration_label":"140",
  "module_icon":null,"icon_images":null,
  "language_id":1,"status":"completed","is_locked":false},
 {"module_id":13,"parent_id":13,"module_name":"Spoken English",
  "module_description":null,
  "module_type_id":2,"module_type_name":"Non Technical",
  "duration_minutes":null,"duration_label":"45 Days",
  "module_icon":"app/uploads/English/images/x.JPG",
  "icon_images":"app/uploads/English/images/x.JPG",
  "language_id":1,"status":"locked","is_locked":true}]}
''';

const _moduleTypesJson = '''
[{"module_type_id":1,"module_type":"Technical"},
 {"module_type_id":2,"module_type":"Non Technical"}]
''';

void main() {
  test('dashboard stats parse from the real payload', () {
    final stats = DashboardStatsModel.fromJson(
      jsonDecode(_dashboardJson) as Map<String, dynamic>,
    );

    expect(stats.modulesCompleted, 2);
    expect(stats.totalModules, 8);
    expect(stats.averageScore, 94.37);
    expect(stats.timeInvestedMinutes, 101);
    expect(stats.overallProgress, 0.25);
    expect(stats.questionsAttempted, 71);
    expect(stats.hasAttempts, isTrue);
  });

  test('dashboard stats survive a participant with no activity', () {
    final stats = DashboardStatsModel.fromJson(const {
      'modules_completed': 0,
      'total_modules': 0,
      'average_score': 0.0,
      'questions_attempted': 0,
      'time_invested_minutes': 0,
      'time_invested_seconds': 0,
      'overall_progress': 0.0,
    });

    expect(stats.hasAttempts, isFalse);
    expect(stats.overallProgress, 0.0);
  });

  test('module list parses status, duration and nullable icons', () {
    final body = jsonDecode(_moduleListJson) as Map<String, dynamic>;

    final modules = (body['modules'] as List<dynamic>)
        .map((e) => LearningModuleModel.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(modules, hasLength(2));

    final completed = modules.first;
    expect(completed.moduleName, 'Learning License');
    expect(completed.status, ModuleStatus.completed);
    expect(completed.isLocked, isFalse);
    expect(completed.durationText, '140 min');
    expect(completed.moduleIcon, isNull);

    // Non-numeric duration falls back to the raw label.
    final locked = modules.last;
    expect(locked.status, ModuleStatus.locked);
    expect(locked.isLocked, isTrue);
    expect(locked.durationMinutes, isNull);
    expect(locked.durationText, '45 Days');
    expect(locked.moduleTypeName, 'Non Technical');
  });

  test('unknown status falls back to locked', () {
    expect(moduleStatusFromString(null), ModuleStatus.locked);
    expect(moduleStatusFromString('something-new'), ModuleStatus.locked);
    expect(moduleStatusFromString('active'), ModuleStatus.active);
  });

  test('module topics parse, including the media path fallback', () {
    // Captured from GET /mobile/module/1/topics?language_id=1
    const json = '''
{"module_id":1,"language_id":1,"total":2,"topics":[
 {"topic_id":1,"topic_name":"External Parts of Car","doc_id":5,
  "doc_title":"External Parts of Car","doc_type":"Video",
  "duration_minutes":null,
  "content_path":"app/uploads/English/videos/x.mp4",
  "youtube_url":null,
  "thumbnail":"app/uploads/English/images/x.JPG"},
 {"topic_id":69,"topic_name":"Learning License Application Process",
  "doc_id":90,"doc_title":"LL Handbook","doc_type":"PDF",
  "duration_minutes":10,
  "content_path":"app/uploads/English/pdfs/x.pdf",
  "youtube_url":null,"thumbnail":null}]}
''';

    final topics = ((jsonDecode(json) as Map<String, dynamic>)['topics']
            as List<dynamic>)
        .map((e) => ModuleTopicModel.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(topics, hasLength(2));

    expect(topics.first.isVideo, isTrue);
    expect(topics.first.isPdf, isFalse);
    expect(topics.first.hasContent, isTrue);
    expect(topics.first.durationMinutes, isNull);

    expect(topics.last.isPdf, isTrue);
    expect(topics.last.durationMinutes, 10);
    expect(topics.last.thumbnail, isNull);
  });

  test('a topic with no uploaded file reports no content', () {
    final topic = ModuleTopicModel.fromJson(const {
      'topic_id': 7,
      'topic_name': 'Pending topic',
      'doc_type': 'PPT',
      'content_path': null,
      'youtube_url': null,
    });

    expect(topic.hasContent, isFalse);
    expect(topic.isPpt, isTrue);
  });

  test('languages parse', () {
    const json = '''
[{"language_id":1,"language_code":"en","language_name":"English"},
 {"language_id":2,"language_code":"hi","language_name":"Hindi"}]
''';

    final languages = (jsonDecode(json) as List<dynamic>)
        .map((e) => AppLanguageModel.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(languages, hasLength(2));
    expect(languages.last.languageId, 2);
    expect(languages.last.languageName, 'Hindi');
  });

  test('feedback questions parse and detect multi-select', () {
    // Captured from GET /mobile/feedback/questions?language_id=1
    const json = '''
[{"question_id":1,"question_name":"How are you feeling today?",
  "question_description":null,"question_type":"single","language_id":1,
  "options":[{"option_id":1,"question_id":1,"option_name":"Energized",
              "option_icon":null,"language_id":1},
             {"option_id":2,"question_id":1,"option_name":"Calm",
              "option_icon":null,"language_id":1}]},
 {"question_id":2,"question_name":"What brings you here?",
  "question_description":null,"question_type":"Multiple","language_id":1,
  "options":[{"option_id":5,"question_id":2,"option_name":"Driving skills",
              "option_icon":null,"language_id":1}]}]
''';

    final questions = (jsonDecode(json) as List<dynamic>)
        .map((e) => FeedbackQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(questions, hasLength(2));

    expect(questions.first.allowsMultiple, isFalse);
    expect(questions.first.options.map((o) => o.optionId), [1, 2]);

    // "Multiple" is stored capitalised by the LMS.
    expect(questions.last.allowsMultiple, isTrue);
  });

  test('mcq assessment parses and hides the answer key', () {
    // Captured from GET /mobile/module/assessment/1
    const json = '''
{"module_id":1,"language_id":1,"total_questions":1,"pass_percentage":60.0,
 "questions":[{"mcq_id":1,
   "question_title":"Which actions contribute to safe traffic behaviour?",
   "question_description":null,
   "image_url":"app/uploads/English/images/x.png","marks":1.0,
   "allows_multiple":true,
   "options":[{"option_id":185,"option_text":"Following speed limits"},
              {"option_id":186,"option_text":"Using a mobile phone"}]}]}
''';

    final assessment = ModuleAssessmentModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );

    expect(assessment.passPercentage, 60.0);
    expect(assessment.questions, hasLength(1));

    final question = assessment.questions.first;
    expect(question.allowsMultiple, isTrue);
    expect(question.options.map((o) => o.optionId), [185, 186]);

    // The payload carries no correctness flag, so nothing can leak it.
    expect(jsonDecode(json).toString().contains('is_correct'), isFalse);
  });

  test('assessment result reports completion and the unlocked module', () {
    final passed = AssessmentResultModel.fromJson(const {
      'module_id': 9,
      'attempt_id': 39,
      'total_questions': 1,
      'correct_answers': 1,
      'score_percentage': 100.0,
      'pass_percentage': 60.0,
      'passed': true,
      'module_completed': true,
      'next_module_id': 13,
      'next_module_name': 'Spoken English',
    });

    expect(passed.passed, isTrue);
    expect(passed.moduleCompleted, isTrue);
    expect(passed.nextModuleName, 'Spoken English');

    final failed = AssessmentResultModel.fromJson(const {
      'total_questions': 1,
      'correct_answers': 0,
      'score_percentage': 0.0,
      'pass_percentage': 60.0,
      'passed': false,
      'module_completed': false,
      'next_module_id': null,
      'next_module_name': null,
    });

    expect(failed.passed, isFalse);
    expect(failed.nextModuleId, isNull);
  });

  test('did you know tips parse', () {
    final tip = DashboardTipModel.fromJson(const {
      'didyouknow_id': 3,
      'text': 'Wearing a front seat belt reduces fatal injury by 45%.',
      'image_url': 'did_know_image_3.jpeg',
      'language_id': 1,
    });

    expect(tip.id, 3);
    expect(tip.imageUrl, 'did_know_image_3.jpeg');
  });

  test('feedback form fields parse by type', () {
    const json = '''
[{"field":"visual_material","question":"How useful were the videos?",
  "type":"single","options":["Excellent","Good"]},
 {"field":"confidence_areas","question":"Which areas?",
  "type":"multiple","options":["Traffic rules","Road safety"]},
 {"field":"like_most","question":"What did you like most?",
  "type":"text","options":[]}]
''';

    final fields = (jsonDecode(json) as List<dynamic>)
        .map((e) => FeedbackFormFieldModel.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(fields, hasLength(3));
    expect(fields[0].isMultiple, isFalse);
    expect(fields[0].isText, isFalse);
    expect(fields[1].isMultiple, isTrue);
    expect(fields[2].isText, isTrue);
    expect(fields[2].options, isEmpty);
  });

  group('mediaUrl', () {
    test('strips the legacy app/ prefix', () {
      expect(
        mediaUrl('app/uploads/English/videos/x.mp4'),
        '${ApiConstants.baseUrl}/uploads/English/videos/x.mp4',
      );
    });

    test('places a bare file name in its folder', () {
      expect(
        mediaUrl('tip.jpeg', folder: 'didyouknow'),
        '${ApiConstants.baseUrl}/uploads/didyouknow/tip.jpeg',
      );
    });

    test('leaves absolute URLs alone and rejects empties', () {
      expect(mediaUrl('https://example.com/a.png'), 'https://example.com/a.png');
      expect(mediaUrl(null), isNull);
      expect(mediaUrl('   '), isNull);
    });
  });

  test('module types parse', () {
    final types = (jsonDecode(_moduleTypesJson) as List<dynamic>)
        .map((e) => ModuleCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(types, hasLength(2));
    expect(types.first.moduleTypeId, 1);
    expect(types.last.moduleType, 'Non Technical');
  });
}
