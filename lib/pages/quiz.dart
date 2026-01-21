import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:ui';
import 'package:hometown_quiz/pages/results_page.dart';
import 'package:hometown_quiz/models/fun_fact.dart';
import 'package:hometown_quiz/fun_fact_service.dart';

class QuizPage extends StatefulWidget {
  final String category;

  const QuizPage({super.key, required this.category});

  @override
  State<QuizPage> createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  // Constants
  static const int totalQuestionsToAnswer =
      15; // Total questions user must answer (Requirements: 4.1, 4.2)

  // Simple variables
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String selectedAnswer = '';
  bool isLoading = true;
  int timeLeft = 15; // 15 seconds per question
  Timer? timer;
  String userHometown = '';
  int answeredQuestions =
      0; // Track number of questions actually answered (Requirements: 3.4, 4.2)

  // Feedback and scoring state variables (Requirements 1.1, 2.1)
  bool showingFeedback = false;
  bool? isCorrect;
  int totalScore = 0;
  int correctAnswers = 0;
  int totalTimeBonus = 0;
  int answerTime = 0;

  // Fun fact modal state variables (Requirements: 2.1)
  bool showFunFactModal = false;
  FunFact? currentFunFact;
  // Track which milestones (5, 10, 15) have already used the fun fact button
  Set<int> usedFunFactMilestones = {};

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

      // Get 18 random questions for this category and hometown (15 + buffer for potential skips)
      // Requirements: 4.1
      final response = await Supabase.instance.client
          .from('questions')
          .select()
          .eq('city', userHometown)
          .eq('category', widget.category)
          .limit(18);

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

  /// Calculates points for an answer based on correctness and time taken.
  /// Returns 11 points for correct answers under 5 seconds (10 base + 10% bonus),
  /// 10 points for correct answers 5+ seconds, 0 for incorrect.
  /// (Requirements 2.1, 2.2, 2.3)
  static int calculatePoints(bool isCorrect, int timeTaken) {
    if (!isCorrect) return 0;

    const int basePoints = 10;
    if (timeTaken < 5) {
      // 10% bonus for answering under 5 seconds
      return (basePoints * 1.1).round(); // 11 points
    }
    return basePoints;
  }

  /// Formats the progress display string showing current question number out of total.
  /// Returns "Q {answeredQuestions + 1} of 15" format.
  /// (Requirements: 4.2)
  /// **Feature: fun-facts-feature, Property 5: Progress display format correctness**
  static String formatProgressDisplay(int answeredQuestions) {
    return 'Q${answeredQuestions + 1} of $totalQuestionsToAnswer';
  }

  /// Determines if the fun facts button should be visible based on the current question number.
  /// Returns true when (answeredQuestions + 1) equals 5, 10, or 15.
  /// Returns false for all other question numbers.
  /// (Requirements: 1.1, 1.2)
  /// **Feature: fun-facts-feature, Property 1: Fun facts button visibility based on question number**
  static bool isFunFactButtonVisible(int answeredQuestions) {
    final questionNumber = answeredQuestions + 1;
    return questionNumber == 5 || questionNumber == 10 || questionNumber == 15;
  }

  /// Instance method wrapper for _isFunFactButtonVisible
  /// Also checks if the current milestone has already been used
  bool _isFunFactButtonVisible() {
    final questionNumber = answeredQuestions + 1;
    // Check if this is a milestone question AND hasn't been used yet
    return isFunFactButtonVisible(answeredQuestions) &&
        !usedFunFactMilestones.contains(questionNumber);
  }

  /// Shows the fun fact modal by pausing timer, fetching a random fact, and displaying the modal
  /// Marks the current milestone as used so button won't appear again
  /// (Requirements: 2.1, 2.2)
  Future<void> _showFunFactModal() async {
    // Mark this milestone as used (one-time click only)
    final questionNumber = answeredQuestions + 1;
    setState(() {
      usedFunFactMilestones.add(questionNumber);
    });

    // Pause the timer
    timer?.cancel();

    // Fetch random fun fact from FunFactService
    final funFact = await FunFactService.getRandomFunFact();

    if (funFact != null) {
      // Set currentFunFact and show modal
      setState(() {
        currentFunFact = funFact;
        showFunFactModal = true;
      });
    } else {
      // Handle fetch error with snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load fun fact. Please try again.'),
            backgroundColor: Color(0xFFDC3545),
          ),
        );
        // Restart timer since we couldn't show the modal
        startTimer();
      }
    }
  }

  /// Closes the fun fact modal and replaces the current question with a new one
  /// The current question is skipped (neutral - no points lost or gained)
  /// (Requirements: 3.1, 3.2, 3.3, 3.4)
  Future<void> _closeFunFactModal() async {
    // Close the modal
    setState(() {
      showFunFactModal = false;
      currentFunFact = null;
    });

    // Remove current question from list (skip it - no score change)
    // Note: We do NOT modify totalScore, correctAnswers, or answeredQuestions
    // This ensures score invariance during skip (Requirements: 3.2, 3.3)
    if (questions.isNotEmpty && currentQuestionIndex < questions.length) {
      questions.removeAt(currentQuestionIndex);
    }

    // Fetch one extra question and add to list (Requirements: 3.4)
    await _fetchExtraQuestion();

    // Reset selected answer for the new question
    setState(() {
      selectedAnswer = '';
    });

    // Reset timer and start for new question
    startTimer();
  }

  /// Fetches one additional question from Supabase for the same category/hometown
  /// and adds it to the questions list
  /// (Requirements: 3.4)
  Future<void> _fetchExtraQuestion() async {
    try {
      // Get existing question IDs to exclude them from the fetch
      final existingIds = questions.map((q) => q['id']).toList();

      // Build query for fetching additional question
      var query = Supabase.instance.client
          .from('questions')
          .select()
          .eq('city', userHometown)
          .eq('category', widget.category);

      // Only add the NOT IN filter if we have existing IDs to exclude
      if (existingIds.isNotEmpty) {
        // Format IDs as a comma-separated string in parentheses for the filter
        final idsString = '(${existingIds.join(',')})';
        query = query.not('id', 'in', idsString);
      }

      final response = await query.limit(1);

      if (response.isNotEmpty) {
        setState(() {
          questions.add(Map<String, dynamic>.from(response[0]));
        });
      }
    } catch (e) {
      // Handle fetch errors gracefully - show snackbar but continue with remaining questions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load additional question.'),
            backgroundColor: Color(0xFFDC3545),
          ),
        );
      }
    }
  }

  // Color constants for feedback states
  static const Color greenBackground = Color(0xFFD4EDDA);
  static const Color redBackground = Color(0xFFF8D7DA);
  static const Color greenBorder = Color(0xFF28A745);
  static const Color redBorder = Color(0xFFDC3545);
  static const Color selectedBackground = Color(0xFFFDE8D7);
  static const Color selectedBorder = Color(0xFFF47B25);
  static const Color defaultBorder = Color(0xFFE0E0E0);

  /// Returns the appropriate background color for an answer option based on feedback state.
  /// - Green for correct answer when showing feedback
  /// - Red for selected incorrect answer when showing feedback
  /// - Normal colors when not showing feedback
  /// (Requirements: 1.1, 1.2)
  Color getOptionBackgroundColor(String option, String correctAnswer) {
    return computeOptionBackgroundColor(
      option: option,
      correctAnswer: correctAnswer,
      selectedAnswer: selectedAnswer,
      showingFeedback: showingFeedback,
    );
  }

  /// Static method for computing background color - enables property testing.
  /// (Requirements: 1.1, 1.2)
  static Color computeOptionBackgroundColor({
    required String option,
    required String correctAnswer,
    required String selectedAnswer,
    required bool showingFeedback,
  }) {
    if (!showingFeedback) {
      // Normal state: selected option gets highlight, others get white
      return selectedAnswer == option ? selectedBackground : Colors.white;
    }

    // Feedback state
    if (option == correctAnswer) {
      // Correct answer always shows green
      return greenBackground;
    } else if (option == selectedAnswer && selectedAnswer != correctAnswer) {
      // Selected incorrect answer shows red
      return redBackground;
    }

    // Other options stay white during feedback
    return Colors.white;
  }

  /// Returns the appropriate border color for an answer option based on feedback state.
  /// - Green border for correct answer when showing feedback
  /// - Red border for selected incorrect answer when showing feedback
  /// - Normal colors when not showing feedback
  /// (Requirements: 1.1, 1.2)
  Color getOptionBorderColor(String option, String correctAnswer) {
    return computeOptionBorderColor(
      option: option,
      correctAnswer: correctAnswer,
      selectedAnswer: selectedAnswer,
      showingFeedback: showingFeedback,
    );
  }

  /// Static method for computing border color - enables property testing.
  /// (Requirements: 1.1, 1.2)
  static Color computeOptionBorderColor({
    required String option,
    required String correctAnswer,
    required String selectedAnswer,
    required bool showingFeedback,
  }) {
    if (!showingFeedback) {
      // Normal state: selected option gets orange border, others get gray
      return selectedAnswer == option ? selectedBorder : defaultBorder;
    }

    // Feedback state
    if (option == correctAnswer) {
      // Correct answer always shows green border
      return greenBorder;
    } else if (option == selectedAnswer && selectedAnswer != correctAnswer) {
      // Selected incorrect answer shows red border
      return redBorder;
    }

    // Other options stay gray during feedback
    return defaultBorder;
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
          // Time's up! Call submitAnswer with no selection (treats as incorrect)
          // (Requirements: 1.3, 2.4)
          timer.cancel();
          submitAnswer();
        }
      });
    });
  }

  /// Submits the current answer, calculates score, and shows feedback.
  /// If no answer is selected (e.g., timer expired), treats as incorrect.
  /// (Requirements: 1.1, 1.4, 2.1, 2.2, 2.3)
  void submitAnswer() {
    // Don't submit if already showing feedback
    if (showingFeedback) return;

    // Stop the timer
    timer?.cancel();

    // Calculate answer time (15 - timeLeft)
    answerTime = 15 - timeLeft;

    // Get the correct answer from the question
    final question = questions[currentQuestionIndex];
    final correctAnswer = question['correct_answer'] as String;

    // Check if the answer is correct
    final answerIsCorrect =
        selectedAnswer.isNotEmpty && selectedAnswer == correctAnswer;

    // Calculate points and update totals
    final points = calculatePoints(answerIsCorrect, answerTime);

    setState(() {
      isCorrect = answerIsCorrect;
      totalScore += points;
      answeredQuestions++; // Increment answered questions count (Requirements: 3.4, 4.3)
      if (answerIsCorrect) {
        correctAnswers++;
        // Track time bonus points separately for display purposes
        // Each fast answer (under 5 seconds) earns 1 bonus point (11 - 10 = 1)
        // Note: totalScore already includes these bonus points via calculatePoints()
        if (answerTime < 5) {
          totalTimeBonus += 1;
        }
      }
      showingFeedback = true;
    });

    // Show feedback for 1.5 seconds before advancing
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        goToNextQuestion();
      }
    });
  }

  // Go to next question
  void goToNextQuestion() {
    setState(() {
      showingFeedback = false;
      isCorrect = null;
      selectedAnswer = '';
    });

    // Check if user has answered all 15 questions (Requirements: 4.3)
    if (answeredQuestions >= totalQuestionsToAnswer) {
      // Quiz finished - navigate to ResultsPage with accumulated stats
      // (Requirements: 3.1, 3.2, 3.3, 3.4, 3.5)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            totalScore: totalScore,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestionsToAnswer,
            timeBonus: totalTimeBonus,
            category: widget.category,
          ),
        ),
      );
    } else if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      startTimer();
    } else {
      // No more questions available but haven't reached 15 - navigate to results anyway
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            totalScore: totalScore,
            correctAnswers: correctAnswers,
            totalQuestions: answeredQuestions,
            timeBonus: totalTimeBonus,
            category: widget.category,
          ),
        ),
      );
    }
  }

  /// Builds the fun fact modal overlay widget
  /// Displays lightbulb icon, "Fun Fact!" title, fact content, category label, and "Continue Quiz" button
  /// (Requirements: 2.3, 2.4)
  Widget _buildFunFactModal() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lightbulb icon header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8D7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    size: 40,
                    color: Color(0xFFF47B25),
                  ),
                ),
                const SizedBox(height: 16),
                // "Fun Fact!" title
                const Text(
                  'Fun Fact!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF221710),
                  ),
                ),
                const SizedBox(height: 16),
                // Fact content text
                if (currentFunFact != null)
                  Text(
                    currentFunFact!.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF221710),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                // Category label chip
                if (currentFunFact != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      currentFunFact!.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // "Continue Quiz" button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _closeFunFactModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF47B25),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue Quiz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

    // Parse options for MCQ - options is stored as a Map like {"A": "value", "B": "value"}
    if (questionType == 'mcq' && question['options'] != null) {
      final optionsData = question['options'];
      if (optionsData is Map) {
        // Convert Map values to List of strings (e.g., {"A": "Bengali", "B": "Sylheti"} -> ["Bengali", "Sylheti"])
        options = optionsData.values.map((v) => v.toString()).toList();
      } else if (optionsData is List) {
        options = List<String>.from(optionsData);
      }
    } else if (questionType == 'true_false') {
      options = ['True', 'False'];
    }

    return Stack(
      children: [
        Scaffold(
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
                      // Question number - shows "Q X of 15" format (Requirements: 4.2)
                      Text(
                        formatProgressDisplay(answeredQuestions),
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
                          final correctAnswer =
                              question['correct_answer'] as String;
                          final backgroundColor = getOptionBackgroundColor(
                            option,
                            correctAnswer,
                          );
                          final borderColor = getOptionBorderColor(
                            option,
                            correctAnswer,
                          );
                          // Determine if this option should have bold border (selected or feedback highlight)
                          final hasBoldBorder =
                              isSelected ||
                              (showingFeedback &&
                                  (option == correctAnswer ||
                                      (option == selectedAnswer &&
                                          selectedAnswer != correctAnswer)));

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              // Disable tap interaction while showing feedback (Requirement 1.4)
                              onTap: showingFeedback
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedAnswer = option;
                                      });
                                    },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderColor,
                                    width: hasBoldBorder ? 2 : 1,
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
                        }),

                        // Fun Facts Button - visible on questions 5, 10, 15
                        // Positioned below answer options as per mockup
                        // (Requirements: 1.1, 1.2, 1.3)
                        if (_isFunFactButtonVisible())
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: GestureDetector(
                              onTap: _showFunFactModal,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDE8D7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFF47B25,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.lightbulb,
                                      size: 24,
                                      color: Color(0xFFF47B25),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Fun Fact',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF221710),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 24,
                                      color: Color(0xFF221710),
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

                // Bottom section with progress bar and next button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Progress bar with text above (Requirements: 4.2)
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
                                '${((answeredQuestions + 1) / totalQuestionsToAnswer * 100).toInt()}%',
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
                                  (answeredQuestions + 1) /
                                  totalQuestionsToAnswer,
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
                          // Disable button if no answer selected or if showing feedback
                          // (Requirements: 1.1, 1.4)
                          onPressed: (selectedAnswer.isEmpty || showingFeedback)
                              ? null
                              : () {
                                  submitAnswer();
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
        ),
        // Fun fact modal overlay (Requirements: 2.1, 2.3, 2.4)
        if (showFunFactModal) _buildFunFactModal(),
      ],
    );
  }
}
