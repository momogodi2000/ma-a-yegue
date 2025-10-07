import 'package:flutter/material.dart';
import 'package:maa_yegue/features/lessons/domain/entities/course.dart';
import 'package:maa_yegue/features/lessons/domain/entities/lesson.dart';
import 'package:maa_yegue/features/lessons/domain/entities/lesson_content.dart';
import 'package:maa_yegue/features/lessons/data/services/course_service.dart';

/// View for creating quiz content within lessons
class QuizCreationView extends StatefulWidget {
  final Course course;
  final Lesson? lesson; // If null, create new lesson for quiz

  const QuizCreationView({Key? key, required this.course, this.lesson})
    : super(key: key);

  @override
  State<QuizCreationView> createState() => _QuizCreationViewState();
}

class _QuizCreationViewState extends State<QuizCreationView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<QuizQuestion> _questions = [];
  bool _isLoading = false;
  int _passingScore = 70; // Default 70%

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _titleController.text = widget.lesson!.title;
      _descriptionController.text = widget.lesson!.description;
      // TODO: Load existing questions if editing
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        QuizQuestion(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          question: '',
          type: QuestionType.multipleChoice,
          options: ['', '', '', ''],
          correctAnswer: 0,
          points: 1,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _updateQuestion(int index, QuizQuestion question) {
    setState(() {
      _questions[index] = question;
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one question'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate all questions
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.question.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question ${i + 1} cannot be empty'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (question.type == QuestionType.multipleChoice ||
          question.type == QuestionType.trueFalse) {
        if (question.options.any((option) => option.trim().isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All options for question ${i + 1} must be filled'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      // Create or update lesson with quiz content
      final lesson =
          widget.lesson ??
          Lesson(
            id: '', // Will be generated
            courseId: widget.course.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            order: widget.course.lessons.length + 1,
            type: LessonType.assessment,
            status: LessonStatus.available,
            estimatedDuration: _questions.length * 2, // 2 minutes per question
            thumbnailUrl: '',
            contents: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      // Create quiz content
      final quizContent = LessonContent(
        id: '', // Will be generated
        lessonId: lesson.id,
        type: ContentType.quiz,
        content: _serializeQuizData(),
        order: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'passingScore': _passingScore,
          'totalQuestions': _questions.length,
          'totalPoints': _questions.fold(0, (sum, q) => sum + q.points),
        },
      );

      // Create lesson and content using service
      final courseService = CourseService();
      final lessonId = await courseService.createLesson(lesson);

      // Update content with the actual lesson ID
      final updatedContent = quizContent.copyWith(lessonId: lessonId);
      final contentId = await courseService.createLessonContent(updatedContent);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quiz saved successfully with ID: $contentId'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _serializeQuizData() {
    // TODO: Implement proper JSON serialization
    return 'Quiz data: ${_questions.length} questions';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson != null ? 'Edit Quiz' : 'Create Quiz'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveQuiz,
            child: Text(
              'SAVE',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quiz Information
                    _buildSectionTitle('Quiz Information'),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Quiz Title *',
                        hintText: 'Enter quiz title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Quiz title is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Brief description of the quiz',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Passing Score
                    Row(
                      children: [
                        const Text('Passing Score: '),
                        Expanded(
                          child: Slider(
                            value: _passingScore.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: '$_passingScore%',
                            onChanged: (value) {
                              setState(() => _passingScore = value.toInt());
                            },
                          ),
                        ),
                        Text('$_passingScore%'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Questions Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Questions (${_questions.length})'),
                        ElevatedButton.icon(
                          onPressed: _addQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Question'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (_questions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.quiz,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No questions added yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Click "Add Question" to start building your quiz',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _questions.removeAt(oldIndex);
                            _questions.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          return QuestionBuilderWidget(
                            key: ValueKey(_questions[index].id),
                            question: _questions[index],
                            questionNumber: index + 1,
                            onUpdate: (question) =>
                                _updateQuestion(index, question),
                            onDelete: () => _removeQuestion(index),
                          );
                        },
                      ),

                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveQuiz,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Quiz',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

/// Widget for building individual quiz questions
class QuestionBuilderWidget extends StatefulWidget {
  final QuizQuestion question;
  final int questionNumber;
  final Function(QuizQuestion) onUpdate;
  final VoidCallback onDelete;

  const QuestionBuilderWidget({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<QuestionBuilderWidget> createState() => _QuestionBuilderWidgetState();
}

class _QuestionBuilderWidgetState extends State<QuestionBuilderWidget> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late QuizQuestion _currentQuestion;

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.question;
    _questionController = TextEditingController(
      text: _currentQuestion.question,
    );
    _optionControllers = _currentQuestion.options
        .map((option) => TextEditingController(text: option))
        .toList();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuestion() {
    final updatedQuestion = _currentQuestion.copyWith(
      question: _questionController.text,
      options: _optionControllers.map((c) => c.text).toList(),
    );
    widget.onUpdate(updatedQuestion);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${widget.questionNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Question type selector
                    DropdownButton<QuestionType>(
                      value: _currentQuestion.type,
                      items: QuestionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getQuestionTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _currentQuestion = _currentQuestion.copyWith(
                              type: value,
                            );
                            _updateQuestion();
                          });
                        }
                      },
                    ),
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Question text
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question *',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _updateQuestion(),
            ),

            const SizedBox(height: 16),

            // Answer options based on type
            if (_currentQuestion.type == QuestionType.multipleChoice)
              ..._buildMultipleChoiceOptions()
            else if (_currentQuestion.type == QuestionType.trueFalse)
              _buildTrueFalseOptions()
            else if (_currentQuestion.type == QuestionType.shortAnswer)
              _buildShortAnswerField(),

            const SizedBox(height: 16),

            // Points
            Row(
              children: [
                const Text('Points: '),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: _currentQuestion.points.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final points = int.tryParse(value) ?? 1;
                      setState(() {
                        _currentQuestion = _currentQuestion.copyWith(
                          points: points,
                        );
                        _updateQuestion();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMultipleChoiceOptions() {
    final widgets = <Widget>[];

    for (int i = 0; i < _optionControllers.length; i++) {
      widgets.add(
        Row(
          children: [
            Radio<int>(
              value: i,
              groupValue: _currentQuestion.correctAnswer,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentQuestion = _currentQuestion.copyWith(
                      correctAnswer: value,
                    );
                    _updateQuestion();
                  });
                }
              },
            ),
            Expanded(
              child: TextFormField(
                controller: _optionControllers[i],
                decoration: InputDecoration(
                  labelText: 'Option ${String.fromCharCode(65 + i)} *',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => _updateQuestion(),
              ),
            ),
          ],
        ),
      );

      if (i < _optionControllers.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
  }

  Widget _buildTrueFalseOptions() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<int>(
            title: const Text('True'),
            value: 0,
            groupValue: _currentQuestion.correctAnswer,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _currentQuestion = _currentQuestion.copyWith(
                    options: ['True', 'False'],
                    correctAnswer: value,
                  );
                  _updateQuestion();
                });
              }
            },
          ),
        ),
        Expanded(
          child: RadioListTile<int>(
            title: const Text('False'),
            value: 1,
            groupValue: _currentQuestion.correctAnswer,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _currentQuestion = _currentQuestion.copyWith(
                    options: ['True', 'False'],
                    correctAnswer: value,
                  );
                  _updateQuestion();
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShortAnswerField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Expected Answer *',
        hintText: 'Enter the correct short answer',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _currentQuestion = _currentQuestion.copyWith(
            options: [value],
            correctAnswer: 0,
          );
          _updateQuestion();
        });
      },
    );
  }

  String _getQuestionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.shortAnswer:
        return 'Short Answer';
    }
  }
}

/// Quiz question data model
class QuizQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final int correctAnswer;
  final int points;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.points,
  });

  QuizQuestion copyWith({
    String? id,
    String? question,
    QuestionType? type,
    List<String>? options,
    int? correctAnswer,
    int? points,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      points: points ?? this.points,
    );
  }
}

/// Question type enumeration
enum QuestionType { multipleChoice, trueFalse, shortAnswer }
