import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/media_url.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/colors.dart';
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
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: avatar == null
                  ? const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 40,
                    )
                  : ClipOval(
                      child: Image.network(
                        avatar,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
            ),
            accountName: Text(
              participant?.participantName ?? 'User',
              style: const TextStyle(fontSize: 18),
            ),
            accountEmail: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.profile);
              },
              child: Text(
                AppStrings.of('view_profile', lang),
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(AppStrings.of('dashboard', lang)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppStrings.of('change_language', lang)),
            subtitle: languageState.currentName.isEmpty
                ? null
                : Text(languageState.currentName),
            onTap: () {
              Navigator.pop(context);
              showLanguagePicker(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: Text(AppStrings.of('feedback', lang)),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.feedback);
            },
          ),
          const Spacer(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppStrings.of('logout', lang)),
            onTap: () async {
              Navigator.pop(context);

              await ref.read(loginViewModelProvider.notifier).logout();

              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
