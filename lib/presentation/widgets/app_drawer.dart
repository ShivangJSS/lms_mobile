import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/media_url.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
import '../viewmodels/language_view_model.dart';
import '../viewmodels/login_view_model.dart';
import 'language_picker_dialog.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participant = ref.watch(loginViewModelProvider).user;
    final languageState = ref.watch(languageProvider);
    final lang = languageState.languageId;

    final avatar = mediaUrl(participant?.images, folder: 'participants');

    return Drawer(
      backgroundColor: AppColors.surface,
      // SafeArea + a scrollable middle section keep Logout reachable on
      // short screens; a plain Column with a Spacer pushed it off-screen
      // once the header and menu items grew.
      child: Column(
        children: [
          _GlossyDrawerHeader(
            avatar: avatar,
            name: participant?.participantName ?? 'User',
            viewProfileLabel: AppStrings.of('view_profile', lang),
            onViewProfile: () {
              Navigator.pop(context);
              context.push(AppRoutes.profile);
            },
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard,
                  label: AppStrings.of('dashboard', lang),
                  selected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.menu_book,
                  label: AppStrings.of('view_all_modules', lang),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.modules);
                  },
                ),
                _DrawerItem(
                  icon: Icons.language,
                  label: AppStrings.of('change_language', lang),
                  subtitle: languageState.currentName.isEmpty
                      ? null
                      : languageState.currentName,
                  onTap: () {
                    Navigator.pop(context);
                    showLanguagePicker(context, ref);
                  },
                ),
                _DrawerItem(
                  icon: Icons.feedback,
                  label: AppStrings.of('feedback', lang),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.feedback);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.hairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: SafeArea(
              top: false,
              child: _DrawerItem(
                icon: Icons.logout,
                label: AppStrings.of('logout', lang),
                danger: true,
                onTap: () async {
                  Navigator.pop(context);

                  await ref.read(loginViewModelProvider.notifier).logout();

                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glossy brand-gradient drawer header with a wet sheen and glass avatar badge.
class _GlossyDrawerHeader extends StatelessWidget {
  final String? avatar;
  final String name;
  final String viewProfileLabel;
  final VoidCallback onViewProfile;

  const _GlossyDrawerHeader({
    required this.avatar,
    required this.name,
    required this.viewProfileLabel,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppGloss.header(r: AppGloss.radiusLg),
      child: Stack(
        children: [
          AppGloss.sheen(r: AppGloss.radiusLg),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    padding: const EdgeInsets.all(4),
                    decoration: AppGloss.glass(r: 40, opacity: 0.18),
                    child: ClipOval(
                      child: avatar == null
                          ? Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            )
                          : Image.network(
                              avatar!,
                              width: 68,
                              height: 68,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.white,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: onViewProfile,
                    child: Text(
                      viewProfileLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A clean rounded drawer row with a subtle selected/hover tint.
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool selected;
  final bool danger;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.selected = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = danger ? AppColors.error : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppGloss.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppGloss.radiusSm),
          hoverColor: AppColors.primary.withValues(alpha: 0.05),
          child: ListTile(
            dense: subtitle == null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppGloss.radiusSm),
              side: selected
                  ? BorderSide(color: AppColors.primary.withValues(alpha: 0.18))
                  : BorderSide.none,
            ),
            leading: Icon(icon, color: accent),
            title: Text(
              label,
              style: TextStyle(
                color: danger ? AppColors.error : AppColors.textPrimary,
                fontWeight:
                    (selected || danger) ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            subtitle: subtitle == null ? null : Text(subtitle!),
          ),
        ),
      ),
    );
  }
}
