import 'package:equatable/equatable.dart';

/// Mirrors the `status` string returned by GET /mobile/module/list, which the
/// backend derives from participant_module.lock_status.
enum ModuleStatus { completed, active, locked }

ModuleStatus moduleStatusFromString(String? value) {
  switch (value) {
    case 'completed':
      return ModuleStatus.completed;
    case 'active':
      return ModuleStatus.active;
    default:
      return ModuleStatus.locked;
  }
}

class LearningModule extends Equatable {
  final int moduleId;
  final int? parentId;

  final String moduleName;
  final String? moduleDescription;

  final int? moduleTypeId;
  final String? moduleTypeName;

  /// Null when the stored duration is not expressed in minutes.
  final int? durationMinutes;

  /// Raw duration value, e.g. "140" or "45 Days".
  final String? durationLabel;

  final String? moduleIcon;
  final String? iconImages;

  final int? languageId;
  final ModuleStatus status;

  const LearningModule({
    required this.moduleId,
    required this.moduleName,
    required this.status,
    this.parentId,
    this.moduleDescription,
    this.moduleTypeId,
    this.moduleTypeName,
    this.durationMinutes,
    this.durationLabel,
    this.moduleIcon,
    this.iconImages,
    this.languageId,
  });

  bool get isLocked => status == ModuleStatus.locked;

  bool get isCompleted => status == ModuleStatus.completed;

  /// "140 min" when the backend could parse minutes, otherwise the raw label
  /// ("45 Days"), otherwise nothing.
  String get durationText {
    if (durationMinutes != null) return '$durationMinutes min';
    if (durationLabel != null && durationLabel!.isNotEmpty) {
      return durationLabel!;
    }
    return '-';
  }

  @override
  List<Object?> get props => [
        moduleId,
        parentId,
        moduleName,
        moduleDescription,
        moduleTypeId,
        moduleTypeName,
        durationMinutes,
        durationLabel,
        moduleIcon,
        iconImages,
        languageId,
        status,
      ];
}

class ModuleCategory extends Equatable {
  final int moduleTypeId;
  final String moduleType;

  const ModuleCategory({
    required this.moduleTypeId,
    required this.moduleType,
  });

  @override
  List<Object?> get props => [moduleTypeId, moduleType];
}

class AppLanguage extends Equatable {
  final int languageId;
  final String? languageCode;
  final String languageName;

  const AppLanguage({
    required this.languageId,
    required this.languageName,
    this.languageCode,
  });

  @override
  List<Object?> get props => [languageId, languageCode, languageName];
}

/// A single topic inside a module, with the document attached to it.
class ModuleTopic extends Equatable {
  final int topicId;
  final String? topicName;

  final int? docId;
  final String? docTitle;

  /// "Video", "PDF" or "PPT".
  final String? docType;

  final int? durationMinutes;

  /// Stored path, relative to the LMS upload root. Not a ready-made URL.
  final String? contentPath;

  final String? youtubeUrl;
  final String? thumbnail;

  const ModuleTopic({
    required this.topicId,
    this.topicName,
    this.docId,
    this.docTitle,
    this.docType,
    this.durationMinutes,
    this.contentPath,
    this.youtubeUrl,
    this.thumbnail,
  });

  bool get isVideo => docType?.toLowerCase() == 'video';

  bool get isPdf => docType?.toLowerCase() == 'pdf';

  bool get isPpt => docType?.toLowerCase() == 'ppt';

  bool get hasContent =>
      (contentPath != null && contentPath!.isNotEmpty) ||
      (youtubeUrl != null && youtubeUrl!.isNotEmpty);

  @override
  List<Object?> get props => [
        topicId,
        topicName,
        docId,
        docTitle,
        docType,
        durationMinutes,
        contentPath,
        youtubeUrl,
        thumbnail,
      ];
}
