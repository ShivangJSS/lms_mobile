import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';

/// Renders a pdf inline.
///
/// flutter_pdfview reads from a local file, so the document is fetched to the
/// cache directory first and reused on the next open.
class PdfView extends StatefulWidget {
  final String url;
  final String? title;

  const PdfView({super.key, required this.url, this.title});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  String? _localPath;
  String? _error;

  int _pages = 0;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    try {
      final dir = await getTemporaryDirectory();

      final name = Uri.parse(widget.url).pathSegments.last;
      final file = File('${dir.path}/$name');

      if (!await file.exists() || await file.length() == 0) {
        await Dio().download(widget.url, file.path);
      }

      if (!mounted) return;

      setState(() => _localPath = file.path);
    } catch (_) {
      if (!mounted) return;

      setState(() => _error = 'This document could not be opened.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _Message(text: _error!);

    if (_localPath == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: PDFView(
            filePath: _localPath!,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) => setState(() => _pages = pages ?? 0),
            onPageChanged: (page, _) => setState(() => _current = page ?? 0),
            onError: (_) => setState(
              () => _error = 'This document could not be opened.',
            ),
          ),
        ),
        if (_pages > 0)
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: SafeArea(
              top: false,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: AppGloss.panel(
                    color: AppColors.tintedPanel,
                    r: AppGloss.radius,
                  ),
                  child: Text(
                    'Page ${_current + 1} of $_pages',
                    textAlign: TextAlign.center,
                    style: AppText.muted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

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
                  Icons.picture_as_pdf,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(text, textAlign: TextAlign.center, style: AppText.muted),
            ],
          ),
        ),
      ),
    );
  }
}
