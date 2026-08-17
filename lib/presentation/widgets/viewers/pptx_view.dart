import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';

/// Shows a PowerPoint deck inline.
///
/// Flutter cannot render pptx and there is no converter on the server, so the
/// backend composes each slide into a PNG once and caches it. This just pages
/// through those images.
class PptxView extends StatefulWidget {
  /// The stored path, e.g. "app/uploads/English/ppts/x.pptx".
  final String storedPath;

  const PptxView({super.key, required this.storedPath});

  @override
  State<PptxView> createState() => _PptxViewState();
}

class _PptxViewState extends State<PptxView> {
  final _controller = PageController();

  List<String> _slides = const [];
  String? _error;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await Dio().get(
        '${ApiConstants.baseUrl}${ApiConstants.media}/pptx/info',
        queryParameters: {'path': widget.storedPath},
        // Composing a long deck takes a few seconds the first time.
        options: Options(receiveTimeout: const Duration(seconds: 90)),
      );

      final slides = (response.data['slides'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      if (!mounted) return;

      setState(() {
        _slides = slides;
        if (slides.isEmpty) _error = 'This presentation has no slides.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _error = 'This presentation could not be opened.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.slideshow,
                size: 56,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(_error!, textAlign: TextAlign.center, style: AppText.muted),
            ],
          ),
        ),
      );
    }

    if (_slides.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.lg),
            Text('Preparing slides…', style: AppText.muted),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) => InteractiveViewer(
              maxScale: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Image.network(
                  _slides[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _page > 0
                    ? () => _controller.previousPage(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        )
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                'Slide ${_page + 1} of ${_slides.length}',
                style: AppText.muted,
              ),
              IconButton(
                onPressed: _page < _slides.length - 1
                    ? () => _controller.nextPage(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        )
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
