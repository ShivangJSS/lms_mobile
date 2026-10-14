import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
import '../../data/datasource/remote/activity_remote_datasource.dart';
import '../../domain/entities/learning_module.dart';
import '../../domain/entities/video_question.dart';
import '../viewmodels/language_view_model.dart';
import 'video_question_card.dart';

/// Opens the post-video questions for [topic] as a modal sheet. Does nothing if
/// the topic is not a video or carries no video id.
Future<void> showVideoQuestions(
  BuildContext context,
  ModuleTopic topic, {
  required int moduleId,
}) {
  if (!topic.isVideoWithId) return Future.value();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VideoQuestionsSheet(topic: topic, moduleId: moduleId),
  );
}

class _VideoQuestionsSheet extends ConsumerStatefulWidget {
  final ModuleTopic topic;
  final int moduleId;

  const _VideoQuestionsSheet({required this.topic, required this.moduleId});

  @override
  ConsumerState<_VideoQuestionsSheet> createState() =>
      _VideoQuestionsSheetState();
}

class _VideoQuestionsSheetState extends ConsumerState<_VideoQuestionsSheet> {
  final _ds = ActivityRemoteDataSource();

  List<VideoQuizQuestion> _questions = const [];
  final Map<int, Set<int>> _selected = {};

  bool _loading = true;
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final questions = await _ds.getVideoQuestions(
        videoId: widget.topic.videoId!,
        languageId: ref.read(languageProvider).languageId,
      );

      if (!mounted) return;
      setState(() {
        _questions = questions;
        _loading = false;
        if (questions.isEmpty) _error = 'No questions for this video.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load the questions.';
      });
    }
  }

  void _toggle(VideoQuizQuestion q, int optionId) {
    if (_submitted) return;

    setState(() {
      final chosen = _selected.putIfAbsent(q.questionId, () => <int>{});
      if (q.allowsMultiple) {
        chosen.contains(optionId)
            ? chosen.remove(optionId)
            : chosen.add(optionId);
      } else {
        chosen
          ..clear()
          ..add(optionId);
      }
    });
  }

  bool get _canSubmit =>
      _questions.isNotEmpty &&
      _questions.every((q) => (_selected[q.questionId] ?? {}).isNotEmpty);

  Future<void> _submit() async {
    if (!_canSubmit || _submitting) return;

    setState(() => _submitting = true);

    // One answer row per selected option, matching the endpoint's contract.
    final answers = <int, int>{};
    for (final q in _questions) {
      for (final optionId in _selected[q.questionId] ?? const <int>{}) {
        answers[q.questionId] = optionId;
      }
    }

    try {
      await _ds.submitVideoAnswers(
        videoId: widget.topic.videoId!,
        topicId: widget.topic.topicId,
        moduleId: widget.moduleId,
        answers: answers,
      );

      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitted = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Could not save your answers. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      margin: EdgeInsets.only(top: media.padding.top + 40),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(title: widget.topic.topicName ?? 'Video questions'),
          Flexible(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(_error!, style: AppText.muted),
                      )
                    : _body(),
          ),
        ],
      ),
    );
  }

  // Widget _body() {
  //   return ListView.separated(
  //     shrinkWrap: true,
  //     padding: const EdgeInsets.fromLTRB(
  //       AppSpacing.lg,
  //       AppSpacing.md,
  //       AppSpacing.lg,
  //       AppSpacing.lg,
  //     ),
  //     itemCount: _questions.length + 1,
  //     separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
  //     itemBuilder: (context, index) {
  //       if (index == _questions.length) return _footer();
  //
  //       final q = _questions[index];
  //       return VideoQuestionCard(
  //         index: index + 1,
  //         question: q,
  //         selected: _selected[q.questionId] ?? const {},
  //         revealed: _submitted,
  //         onTap: (optionId) => _toggle(q, optionId),
  //       );
  //     },
  //   );
  // }

  Widget _body() {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg +
            bottomInset +
            12, // <--- Adds system navigation bar inset + padding
      ),
      itemCount: _questions.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index == _questions.length) return _footer();

        final q = _questions[index];
        return VideoQuestionCard(
          index: index + 1,
          question: q,
          selected: _selected[q.questionId] ?? const {},
          revealed: _submitted,
          onTap: (optionId) => _toggle(q, optionId),
        );
      },
    );
  }

  Widget _footer() {
    if (_submitted) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 40),
            const SizedBox(height: AppSpacing.sm),
            const Text('Your answers were saved.', style: AppText.label),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        height: AppButton.height,
        child: FilledButton(
          onPressed: _canSubmit && !_submitting ? _submit : null,
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Submit answers'),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppGloss.header(),
      child: Stack(
        children: [
          AppGloss.sheen(r: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
            child: Row(
              children: [
                const Icon(Icons.quiz_rounded, color: Colors.white, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.h3.copyWith(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
