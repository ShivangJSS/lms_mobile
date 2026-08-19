import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';

/// Plays a stored video. The media endpoint answers byte-range requests, so
/// scrubbing works rather than only playing from the start.
class VideoView extends StatefulWidget {
  final String url;

  const VideoView({super.key, required this.url});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController? _controller;
  ChewieController? _chewie;

  String? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

    try {
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _chewie = ChewieController(
          videoPlayerController: controller,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          allowPlaybackSpeedChanging: true,
          aspectRatio: controller.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.primary,
            handleColor: AppColors.primary,
            bufferedColor: AppColors.primaryLight,
          ),
        );
      });
    } catch (e) {
      await controller.dispose();

      if (!mounted) return;

      setState(() => _error = 'This video could not be played.');
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: AppGloss.glass(r: AppGloss.radiusLg, opacity: 0.10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: AppGloss.glass(r: AppGloss.radius, opacity: 0.16),
                  child: const Icon(
                    Icons.videocam_off,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppText.muted.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_chewie == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Chewie(controller: _chewie!),
      ),
    );
  }
}
