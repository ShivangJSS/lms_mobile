import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/colors.dart';
import '../../../data/datasource/local/dummy_feedback_data_source.dart';
import '../../../domain/entities/feedback_question.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final DummyFeedbackDataSource _dataSource =
  DummyFeedbackDataSource();

  List<FeedbackQuestion> _questions = [];

  bool _loading = true;

  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await _dataSource.getFeedbackQuestions();

    setState(() {
      _questions = questions;
      _loading = false;
    });
  }

  void _submitFeedback() async {
    await _dataSource.submitFeedback(_answers);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Feedback Submitted Successfully!',
        ),
      ),
    );

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        title: const Text('Welcome Babita'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        actions: [
          TextButton(
            onPressed: () {
              context.go(AppRoutes.home);
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      body: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEAEA),
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: const Text(
                "Hello and welcome!\n\nWe're excited to have you here. Before we get started, let's get to know you a little better.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ..._questions.map(
                  (question) =>
                  _buildQuestionCard(question),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _submitFeedback,

              style: ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.primary,
                padding:
                const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),

              child: const Text(
                'Submit Feedback',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
      FeedbackQuestion question,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFEBEAEA),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (question.questionType ==
              'single_choice')
            ...question.options.map(
                  (option) => RadioListTile<String>(
                title: Text(option),

                value: option,

                groupValue:
                _answers[question.id] as String?,

                activeColor:
                AppColors.primary,

                onChanged: (value) {
                  setState(() {
                    _answers[question.id] = value;
                  });
                },
              ),
            ),

          if (question.questionType ==
              'multiple_choice')
            ...question.options.map(
                  (option) {
                final selected =
                    (_answers[question.id]
                    as List<String>?)
                        ?.contains(option) ??
                        false;

                return CheckboxListTile(
                  title: Text(option),

                  value: selected,

                  activeColor:
                  AppColors.primary,

                  onChanged: (value) {
                    setState(() {
                      _answers.putIfAbsent(
                        question.id,
                            () => <String>[],
                      );

                      final list =
                      _answers[question.id]
                      as List<String>;

                      if (value == true) {
                        list.add(option);
                      } else {
                        list.remove(option);
                      }
                    });
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}