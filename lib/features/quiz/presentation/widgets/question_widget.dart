import 'package:flutter/material.dart';
import 'package:maa_yegue/features/quiz/domain/entities/quiz_entity.dart';

/// Widget for displaying individual quiz questions
class QuestionWidget extends StatefulWidget {
  final QuestionEntity question;
  final int questionNumber;
  final int totalQuestions;
  final Function(String answer, int timeSpentSeconds) onAnswerSubmitted;
  final bool showResult;
  final String? userAnswer;
  final bool isCorrect;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onAnswerSubmitted,
    this.showResult = false,
    this.userAnswer,
    this.isCorrect = false,
  }) : super(key: key);

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  String? _selectedAnswer;
  final TextEditingController _textController = TextEditingController();
  DateTime? _startTime;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Pre-fill if showing result
    if (widget.showResult && widget.userAnswer != null) {
      if (widget.question.type == QuestionType.fillInBlank) {
        _textController.text = widget.userAnswer!;
      } else {
        _selectedAnswer = widget.userAnswer;
      }
      _hasSubmitted = true;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitAnswer(String answer) {
    if (_hasSubmitted) return;

    final timeSpent = DateTime.now().difference(_startTime!).inSeconds;
    setState(() {
      _hasSubmitted = true;
      if (widget.question.type == QuestionType.fillInBlank) {
        _selectedAnswer = answer;
      }
    });

    widget.onAnswerSubmitted(answer, timeSpent);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            _buildQuestionHeader(),

            const SizedBox(height: 20),

            // Question content
            _buildQuestionContent(),

            const SizedBox(height: 20),

            // Answer input
            _buildAnswerInput(),

            // Result feedback (if showing result)
            if (widget.showResult) _buildResultFeedback(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Question ${widget.questionNumber}/${widget.totalQuestions}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const Spacer(),
        _buildQuestionTypeIcon(),
        const SizedBox(width: 8),
        Text(
          '${widget.question.points} points',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (widget.question.type) {
      case QuestionType.multipleChoice:
        iconData = Icons.list;
        iconColor = Colors.blue;
        break;
      case QuestionType.fillInBlank:
        iconData = Icons.edit;
        iconColor = Colors.green;
        break;
      case QuestionType.audioComprehension:
        iconData = Icons.volume_up;
        iconColor = Colors.orange;
        break;
      case QuestionType.trueFalse:
        iconData = Icons.check_circle;
        iconColor = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildQuestionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Audio player (if applicable)
        if (widget.question.hasAudio) _buildAudioPlayer(),

        // Image (if applicable)
        if (widget.question.hasImage) _buildImage(),

        // Question text
        Text(
          widget.question.question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),

        // Time limit indicator
        if (widget.question.isTimed && !_hasSubmitted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '⏱️ ${widget.question.timeLimitSeconds}s remaining',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // TODO: Implement audio playback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audio playback not implemented yet'),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow, color: Colors.orange),
            iconSize: 32,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Listen to the audio',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement replay
            },
            icon: const Icon(Icons.replay, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(widget.question.imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAnswerInput() {
    switch (widget.question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions();
      case QuestionType.fillInBlank:
        return _buildFillInBlankInput();
      case QuestionType.audioComprehension:
        return _buildAudioComprehensionOptions();
      case QuestionType.trueFalse:
        return _buildTrueFalseOptions();
    }
  }

  Widget _buildMultipleChoiceOptions() {
    return Column(
      children: widget.question.formattedOptions.map((option) {
        final isSelected = _selectedAnswer == option;
        final isCorrectOption =
            widget.showResult && option == widget.question.correctAnswer;
        final isUserSelected = widget.showResult && option == widget.userAnswer;

        Color? backgroundColor;
        Color? borderColor;
        IconData? trailingIcon;

        if (widget.showResult) {
          if (isCorrectOption) {
            backgroundColor = Colors.green[50];
            borderColor = Colors.green[300];
            trailingIcon = Icons.check_circle;
          } else if (isUserSelected && !widget.isCorrect) {
            backgroundColor = Colors.red[50];
            borderColor = Colors.red[300];
            trailingIcon = Icons.cancel;
          } else {
            backgroundColor = Colors.grey[50];
            borderColor = Colors.grey[300];
          }
        } else if (isSelected) {
          backgroundColor = Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.1);
          borderColor = Theme.of(context).primaryColor;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: _hasSubmitted || widget.showResult
                ? null
                : () => _submitAnswer(option),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                  color: borderColor ?? Colors.grey[300]!,
                  width:
                      isSelected ||
                          (widget.showResult &&
                              (isCorrectOption || isUserSelected))
                      ? 2
                      : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      color: isCorrectOption ? Colors.green : Colors.red,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillInBlankInput() {
    return Column(
      children: [
        TextField(
          controller: _textController,
          enabled: !widget.showResult && !_hasSubmitted,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: widget.showResult
                ? (widget.isCorrect ? Colors.green[50] : Colors.red[50])
                : Colors.white,
            suffixIcon: widget.showResult
                ? Icon(
                    widget.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: widget.isCorrect ? Colors.green : Colors.red,
                  )
                : null,
          ),
          onSubmitted: _hasSubmitted ? null : _submitAnswer,
        ),
        const SizedBox(height: 12),
        if (!widget.showResult && !_hasSubmitted)
          ElevatedButton(
            onPressed: () => _submitAnswer(_textController.text.trim()),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Submit Answer'),
          ),
      ],
    );
  }

  Widget _buildAudioComprehensionOptions() {
    // Similar to multiple choice but with audio context
    return _buildMultipleChoiceOptions();
  }

  Widget _buildTrueFalseOptions() {
    return Row(
      children: [
        Expanded(child: _buildTrueFalseButton('True', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildTrueFalseButton('False', Colors.red)),
      ],
    );
  }

  Widget _buildTrueFalseButton(String answer, Color color) {
    final isSelected = _selectedAnswer == answer;
    final isCorrectOption =
        widget.showResult && answer == widget.question.correctAnswer;
    final isUserSelected = widget.showResult && answer == widget.userAnswer;

    Color? backgroundColor;
    Color? borderColor;
    IconData? trailingIcon;

    if (widget.showResult) {
      if (isCorrectOption) {
        backgroundColor = Colors.green[50];
        borderColor = Colors.green[300];
        trailingIcon = Icons.check_circle;
      } else if (isUserSelected && !widget.isCorrect) {
        backgroundColor = Colors.red[50];
        borderColor = Colors.red[300];
        trailingIcon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = color.withValues(alpha: 0.1);
      borderColor = color;
    }

    return InkWell(
      onTap: _hasSubmitted || widget.showResult
          ? null
          : () => _submitAnswer(answer),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor ?? color.withValues(alpha: 0.3),
            width:
                isSelected ||
                    (widget.showResult && (isCorrectOption || isUserSelected))
                ? 2
                : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, color: color, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultFeedback() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isCorrect ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.isCorrect ? Icons.check_circle : Icons.cancel,
                color: widget.isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isCorrect ? 'Correct!' : 'Incorrect',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.isCorrect ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.question.explanation,
            style: TextStyle(
              color: widget.isCorrect ? Colors.green[700] : Colors.red[700],
            ),
          ),
          if (!widget.isCorrect && widget.question.hints.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '💡 Hint: ${widget.question.hints.first}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
