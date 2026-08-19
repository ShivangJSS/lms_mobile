import 'package:flutter/material.dart';

import '../../../core/network/media_url.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../domain/entities/learning_module.dart';
import '../../widgets/viewers/pdf_view.dart';
import '../../widgets/viewers/pptx_view.dart';
import '../../widgets/viewers/unsupported_view.dart';
import '../../widgets/viewers/video_view.dart';

/// Opens a topic's document: video plays inline, pdf renders inline, and
/// anything else (ppt, doc) is handed to an external app.
class TopicViewerScreen extends StatelessWidget {
  final ModuleTopic topic;

  const TopicViewerScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final url = topic.youtubeUrl?.isNotEmpty == true
        ? topic.youtubeUrl
        : mediaUrl(topic.contentPath);

    return Scaffold(
      backgroundColor: topic.isVideo ? Colors.black : AppColors.background,
      appBar: AppBar(
        title: Text(
          topic.topicName ?? 'Topic',
          overflow: TextOverflow.ellipsis,
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.brandGradientRich,
          ),
          child: Stack(children: [AppGloss.sheen(r: 0)]),
        ),
      ),
      body: url == null
          ? const _NotUploaded()
          : _viewer(url),
    );
  }

  Widget _viewer(String url) {
    if (topic.isVideo) return VideoView(url: url);

    if (topic.isPdf) return PdfView(url: url, title: topic.docTitle);

    // Presentations are rendered to slide images by the server and paged
    // through here, rather than being handed to another app.
    if (topic.isPpt && topic.contentPath != null) {
      return PptxView(storedPath: topic.contentPath!);
    }

    return UnsupportedView(
      url: url,
      title: topic.docTitle ?? topic.topicName ?? 'Document',
      docType: topic.docType,
    );
  }
}

class _NotUploaded extends StatelessWidget {
  const _NotUploaded();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: AppGloss.card(r: AppGloss.radiusLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: AppGloss.panel(
                  color: AppColors.tintedPanel,
                  r: AppGloss.radius,
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'This topic has no file uploaded yet.',
                textAlign: TextAlign.center,
                style: AppText.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
