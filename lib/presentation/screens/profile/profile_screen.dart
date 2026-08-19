import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/media_url.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../viewmodels/login_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploading = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(loginViewModelProvider.notifier).loadCurrentUser();
    });
  }

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: AppGloss.card(r: AppGloss.radiusLg),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );

    if (picked == null) return;

    await _upload(File(picked.path));
  }

  Future<void> _upload(File file) async {
    setState(() => _uploading = true);

    try {
      await ApiClient.dio.post(
        ApiConstants.profilePhoto,
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        }),
        // FormData supplies its own multipart boundary; the interceptor's
        // JSON content type would break the upload.
        options: Options(contentType: 'multipart/form-data'),
      );

      // Re-read the participant so the new photo shows everywhere.
      await ref.read(loginViewModelProvider.notifier).loadCurrentUser();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final detail = e is DioException && e.response?.data is Map
          ? e.response?.data['detail']?.toString()
          : null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(detail ?? 'Could not update your photo.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final participant = ref.watch(loginViewModelProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageWash),
        child: participant == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _Header(
                      name: participant.participantName,
                      avatar: _Avatar(
                        url: mediaUrl(
                          participant.images,
                          folder: 'participants',
                        ),
                        uploading: _uploading,
                        onTap: _uploading ? null : _changePhoto,
                      ),
                      onChangePhoto: _uploading ? null : _changePhoto,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      child: Transform.translate(
                        offset: const Offset(0, -22),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration:
                              AppGloss.card(r: 24, shadow: AppGloss.lifted),
                          child: Column(
                            children: [
                              _Field(
                                label: 'Participant ID',
                                value: '${participant.participantId}',
                              ),
                              _Field(
                                label: 'Enrollment No',
                                value: participant.enrollmentNo,
                              ),
                              _Field(
                                label: 'Username',
                                value: participant.username,
                              ),
                              _Field(
                                label: 'Email',
                                value: participant.email ?? '-',
                              ),
                              _Field(
                                label: 'Mobile',
                                value: participant.mobileNo ?? '-',
                              ),
                              _Field(
                                label: 'Progress Status',
                                value: '${participant.progressStatus}',
                              ),
                              _Field(
                                label: 'Course Progress',
                                value: '${participant.courseProgress}%',
                                last: true,
                              ),
                            ],
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

class _Header extends StatelessWidget {
  final String name;
  final Widget avatar;
  final VoidCallback? onChangePhoto;

  const _Header({
    required this.name,
    required this.avatar,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
      decoration: AppGloss.header(r: 36),
      child: Stack(
        children: [
          AppGloss.sheen(r: 36),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Glass badge holding the avatar.
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: AppGloss.glass(r: 68, opacity: 0.18),
                  child: avatar,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: AppText.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  onPressed: onChangePhoto,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppGloss.radiusLg),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Change photo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final bool uploading;
  final VoidCallback? onTap;

  const _Avatar({
    required this.url,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 112,
        height: 112,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.surface,
              child: url == null
                  ? const Icon(
                      Icons.person,
                      size: 62,
                      color: AppColors.primary,
                    )
                  : ClipOval(
                      child: Image.network(
                        url!,
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 62,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
            if (uploading)
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool last;

  const _Field({
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      margin: EdgeInsets.only(bottom: last ? 0 : AppSpacing.sm),
      decoration: AppGloss.panel(
        color: AppColors.surface,
        r: AppGloss.radiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 2),
          Text(value, style: AppText.label),
        ],
      ),
    );
  }
}
