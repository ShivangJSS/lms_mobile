import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/media_url.dart';
import '../../../core/theme/colors.dart';
import '../../viewmodels/login_view_model.dart';

String? _avatarUrl(String? stored) =>
    mediaUrl(stored, folder: 'participants');

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(loginViewModelProvider.notifier).loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final participant = loginState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('View Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: participant == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: _avatarUrl(participant.images) == null
                  ? const Icon(
                      Icons.person,
                      size: 80,
                      color: AppColors.primary,
                    )
                  : ClipOval(
                      child: Image.network(
                        _avatarUrl(participant.images)!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        // The stored value is a path, not a URL, and the
                        // legacy files are not on this server.
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            Text(
              participant.participantName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            _buildProfileItem(
              'Participant ID',
              participant.participantId.toString(),
            ),

            const SizedBox(height: 16),

            _buildProfileItem(
              'Enrollment No',
              participant.enrollmentNo,
            ),

            const SizedBox(height: 16),

            _buildProfileItem(
              'Username',
              participant.username,
            ),

            const SizedBox(height: 16),

            _buildProfileItem(
              'Email',
              participant.email ?? '-',
            ),

            const SizedBox(height: 16),

            _buildProfileItem(
              'Mobile',
              participant.mobileNo ?? '-',
            ),

            const SizedBox(height: 16),

            _buildProfileItem(
              'Progress Status',
              participant.progressStatus.toString(),
            ),

            const SizedBox(height: 16),

            _buildProfileItem(
              'Course Progress',
              '${participant.courseProgress}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}