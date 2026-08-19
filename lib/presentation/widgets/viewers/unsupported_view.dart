import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';

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
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: AppGloss.card(r: AppGloss.radiusLg, shadow: AppGloss.lifted),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradientRich,
                  borderRadius: BorderRadius.circular(AppGloss.radius),
                  boxShadow: AppGloss.soft,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AppGloss.sheen(r: AppGloss.radius),
                    Text(
                      (docType ?? 'FILE').toUpperCase(),
                      style: AppText.h4.copyWith(color: Colors.white),
                    ),
                  ],
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
              DecoratedBox(
                decoration: AppGloss.button(r: AppGloss.radiusSm),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppGloss.radiusSm),
                  child: InkWell(
                    onTap: () => _open(context),
                    borderRadius: BorderRadius.circular(AppGloss.radiusSm),
                    child: SizedBox(
                      height: AppButton.height,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AppGloss.sheen(),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.open_in_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text('Open', style: AppText.button),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
