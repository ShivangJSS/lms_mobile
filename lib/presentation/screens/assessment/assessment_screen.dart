import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../viewmodels/assessment_view_model.dart';
import '../../widgets/radio_option_card.dart';

class AssessmentScreen extends ConsumerWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assessmentViewModelProvider);

    // Listen for successful submission
    ref.listen<AssessmentState>(assessmentViewModelProvider, (previous, next) {
      if (next.isSubmitted && (previous == null || !previous.isSubmitted)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(); // Go back to Home
      }
      if (next.error != null && (previous == null || previous.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trainee Feedback Form'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.questions == null || state.questions!.isEmpty
              ? const Center(child: Text('No questions available'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.questions!.length,
                        itemBuilder: (context, index) {
                          final question = state.questions![index];
                          final selectedAnswer = state.answers[question.id];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 24.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEFEF), // Light gray from screenshot
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question.questionText,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...question.options.map((option) {
                                  return RadioOptionCard(
                                    text: option,
                                    isSelected: selectedAnswer == option,
                                    onTap: () {
                                      ref
                                          .read(assessmentViewModelProvider.notifier)
                                          .answerQuestion(question.id, option);
                                    },
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PrimaryButton(
                        text: 'Submit Feedback',
                        isLoading: state.isSubmitting,
                        onPressed: ref.read(assessmentViewModelProvider.notifier).canSubmit()
                            ? () {
                                ref.read(assessmentViewModelProvider.notifier).submit();
                              }
                            : null, // Disabled if all questions are not answered
                      ),
                    ),
                  ],
                ),
    );
  }
}
