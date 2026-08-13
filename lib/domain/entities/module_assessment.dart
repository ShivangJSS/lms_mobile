import 'package:equatable/equatable.dart';

/// The four kinds of post-session question the LMS stores.
class QuestionType {
  QuestionType._();

  static const String mcq = 'MCQ';
  static const String scq = 'SCQ';
  static const String dropBucket = 'DB';
  static const String matchMaking = 'MM';
}

class ChoiceOption extends Equatable {
  final int optionId;
  final String optionText;

  const ChoiceOption({required this.optionId, required this.optionText});

  @override
  List<Object?> get props => [optionId, optionText];
}

class Bucket extends Equatable {
  final int bucketId;
  final String name;
  final String? image;

  const Bucket({required this.bucketId, required this.name, this.image});

  @override
  List<Object?> get props => [bucketId, name, image];
}

class DraggableItem extends Equatable {
  final int itemId;
  final String name;
  final String? image;

  const DraggableItem({required this.itemId, required this.name, this.image});

  @override
  List<Object?> get props => [itemId, name, image];
}

class MatchItem extends Equatable {
  final int itemId;
  final String text;

  const MatchItem({required this.itemId, required this.text});

  @override
  List<Object?> get props => [itemId, text];
}

/// One question of any type. Only the fields the type needs are populated.
class AssessmentQuestionItem extends Equatable {
  final String type;
  final int questionId;
  final String questionTitle;
  final String? questionDescription;
  final String? imageUrl;
  final double marks;

  // MCQ / SCQ
  final bool allowsMultiple;
  final List<ChoiceOption> options;

  // Drop bucket
  final List<Bucket> buckets;
  final List<DraggableItem> items;

  // Match making
  final List<MatchItem> leftItems;
  final List<MatchItem> rightItems;

  const AssessmentQuestionItem({
    required this.type,
    required this.questionId,
    required this.questionTitle,
    this.questionDescription,
    this.imageUrl,
    this.marks = 1,
    this.allowsMultiple = false,
    this.options = const [],
    this.buckets = const [],
    this.items = const [],
    this.leftItems = const [],
    this.rightItems = const [],
  });

  bool get isChoice =>
      type == QuestionType.mcq || type == QuestionType.scq;

  bool get isDropBucket => type == QuestionType.dropBucket;

  bool get isMatchMaking => type == QuestionType.matchMaking;

  /// Unique across types, since ids only repeat between different banks.
  String get key => '$type-$questionId';

  @override
  List<Object?> get props => [
        type,
        questionId,
        questionTitle,
        questionDescription,
        imageUrl,
        marks,
        allowsMultiple,
        options,
        buckets,
        items,
        leftItems,
        rightItems,
      ];
}

class ModuleAssessment extends Equatable {
  final int moduleId;
  final double passPercentage;
  final List<AssessmentQuestionItem> questions;

  const ModuleAssessment({
    required this.moduleId,
    required this.passPercentage,
    this.questions = const [],
  });

  bool get isEmpty => questions.isEmpty;

  @override
  List<Object?> get props => [moduleId, passPercentage, questions];
}

class AssessmentResult extends Equatable {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;

  /// Of the wrong answers, how many earned some credit.
  final int partiallyCorrect;

  final double scorePercentage;
  final double passPercentage;

  final bool passed;
  final bool moduleCompleted;

  final int? nextModuleId;
  final String? nextModuleName;

  const AssessmentResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.passPercentage,
    required this.passed,
    required this.moduleCompleted,
    this.wrongAnswers = 0,
    this.partiallyCorrect = 0,
    this.nextModuleId,
    this.nextModuleName,
  });

  @override
  List<Object?> get props => [
        totalQuestions,
        correctAnswers,
        wrongAnswers,
        partiallyCorrect,
        scorePercentage,
        passPercentage,
        passed,
        moduleCompleted,
        nextModuleId,
        nextModuleName,
      ];
}
