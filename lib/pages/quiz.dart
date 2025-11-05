import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class QuizPage extends StatefulWidget {
  final String category;

  const QuizPage({super.key, required this.category});

  @override
  State<QuizPage> createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  // Simple variables
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String selectedAnswer = '';
  bool isLoading = true;
  int timeLeft = 15; // 15 seconds per question
  Timer? timer;
  String userHometown = '';

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Get user's hometown and load questions
  Future<void> loadQuestions() async {
    try {
      // Get user's hometown
      String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final userResponse = await Supabase.instance.client
            .from('users')
            .select('hometown')
            .eq('id', userId)
            .single();

        userHometown = userResponse['hometown'] ?? 'Dhaka';
      }

      // Get 10 random questions for this category and hometown
      final response = await Supabase.instance.client
          .from('questions')
          .select()
          .eq('city', userHometown)
          .eq('category', widget.category)
          .limit(10);

      setState(() {
        questions = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });

      // Start timer for first question
      startTimer();
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Start countdown timer
  void startTimer() {
    timeLeft = 15;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          // Time's up! Auto-submit as wrong
          timer.cancel();
          goToNextQuestion();
        }
      });
    });
  }

  // Go to next question
  void goToNextQuestion() {
    timer?.cancel();
    selectedAnswer = '';

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      startTimer();
    } else {
      // Quiz finished
      // TODO: Show results page
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Quiz completed!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F7F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF47B25)),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F7F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No questions available for this category',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];
    final questionType = question['type'];
    List<String> options = [];

    // Parse options for MCQ
    if (questionType == 'mcq' && question['options'] != null) {
      options = List<String>.from(question['options']);
    } else if (questionType == 'true_false') {
      options = ['True', 'False'];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button, question number, and timer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    color: const Color(0xFF221710),
                    onPressed: () {
                      timer?.cancel();
                      Navigator.pop(context);
                    },
                  ),
                  // Question number
                  Text(
                    'Q${currentQuestionIndex + 1} of ${questions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF221710),
                    ),
                  ),
                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: timeLeft > 5
                          ? const Color(0xFFD4EDDA)
                          : const Color(0xFFF8D7DA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: timeLeft > 5
                              ? const Color(0xFF155724)
                              : const Color(0xFF721C24),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${timeLeft}s',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: timeLeft > 5
                                ? const Color(0xFF155724)
                                : const Color(0xFF721C24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Question and options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Question text
                    Text(
                      question['question_text'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF221710),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Answer options
                    ...options.map((option) {
                      final isSelected = selectedAnswer == option;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAnswer = option;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFDE8D7)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF47B25)
                                    : const Color(0xFFE0E0E0),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF221710),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Bottom section with progress bar and next button
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress bar with text above
                  Column(
                    children: [
                      // Progress text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${((currentQuestionIndex + 1) / questions.length * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              (currentQuestionIndex + 1) / questions.length,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF47B25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedAnswer.isEmpty
                          ? null
                          : () {
                              goToNextQuestion();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF47B25),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        disabledForegroundColor: const Color(0xFF9E9E9E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
