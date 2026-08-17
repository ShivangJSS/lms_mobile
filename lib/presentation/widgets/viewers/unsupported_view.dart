import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';

/// PowerPoint and Word cannot be rendered by Flutter, so the file is handed
/// to whichever app on the device can open it.
class UnsupportedView extends StatelessWidget {
  final String url;
  final String title;
  final String? docType;

  const UnsupportedView({
    super.key,
    required this.url,
    required this.title,
    this.docType,
  });

  Future<void> _open(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No app on this device can open this file.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFE64A19),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              alignment: Alignment.center,
              child: Text(
                (docType ?? 'FILE').toUpperCase(),
                style: AppText.h4.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title, textAlign: TextAlign.center, style: AppText.h3),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Presentations open in another app on your device.',
              textAlign: TextAlign.center,
              style: AppText.muted,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () => _open(context),
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}
