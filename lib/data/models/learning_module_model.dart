import '../../domain/entities/learning_module.dart';

class LearningModuleModel extends LearningModule {
  const LearningModuleModel({
    required super.moduleId,
    required super.moduleName,
    required super.status,
    super.parentId,
    super.moduleDescription,
    super.moduleTypeId,
    super.moduleTypeName,
    super.durationMinutes,
    super.durationLabel,
    super.moduleIcon,
    super.iconImages,
    super.languageId,
  });

  factory LearningModuleModel.fromJson(Map<String, dynamic> json) {
    return LearningModuleModel(
      moduleId: _toInt(json['module_id']) ?? 0,
      parentId: _toInt(json['parent_id']),
      moduleName: json['module_name'] as String? ?? 'Untitled module',
      moduleDescription: json['module_description'] as String?,
      moduleTypeId: _toInt(json['module_type_id']),
      moduleTypeName: json['module_type_name'] as String?,
      durationMinutes: _toInt(json['duration_minutes']),
      durationLabel: json['duration_label'] as String?,
      moduleIcon: json['module_icon'] as String?,
      iconImages: json['icon_images'] as String?,
      languageId: _toInt(json['language_id']),
      status: moduleStatusFromString(json['status'] as String?),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class ModuleCategoryModel extends ModuleCategory {
  const ModuleCategoryModel({
    required super.moduleTypeId,
    required super.moduleType,
  });

  factory ModuleCategoryModel.fromJson(Map<String, dynamic> json) {
    return ModuleCategoryModel(
      moduleTypeId: LearningModuleModel._toInt(json['module_type_id']) ?? 0,
      moduleType: json['module_type'] as String? ?? '',
    );
  }
}

class AppLanguageModel extends AppLanguage {
  const AppLanguageModel({
    required super.languageId,
    required super.languageName,
    super.languageCode,
  });

  factory AppLanguageModel.fromJson(Map<String, dynamic> json) {
    return AppLanguageModel(
      languageId: LearningModuleModel._toInt(json['language_id']) ?? 0,
      languageCode: json['language_code'] as String?,
      languageName: json['language_name'] as String? ?? 'Unknown',
    );
  }
}

class ModuleTopicModel extends ModuleTopic {
  const ModuleTopicModel({
    required super.topicId,
    super.topicName,
    super.docId,
    super.docTitle,
    super.docType,
    super.durationMinutes,
    super.contentPath,
    super.youtubeUrl,
    super.thumbnail,
  });

  factory ModuleTopicModel.fromJson(Map<String, dynamic> json) {
    return ModuleTopicModel(
      topicId: LearningModuleModel._toInt(json['topic_id']) ?? 0,
      topicName: json['topic_name'] as String?,
      docId: LearningModuleModel._toInt(json['doc_id']),
      docTitle: json['doc_title'] as String?,
      docType: json['doc_type'] as String?,
      durationMinutes: LearningModuleModel._toInt(json['duration_minutes']),
      contentPath: json['content_path'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }
}
