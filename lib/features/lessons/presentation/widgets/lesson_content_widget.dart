import 'package:flutter/material.dart';
import '../../domain/entities/lesson.dart';

/// Widget for displaying lesson content
class LessonContentWidget extends StatelessWidget {
  final Lesson lesson;

  const LessonContentWidget({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lesson Type Indicator
        _buildLessonTypeIndicator(),
        const SizedBox(height: 16),

        // Content based on lesson type
        _buildContent(context),

        const SizedBox(height: 16),

        // Progress indicator
        _buildProgressIndicator(),

        const SizedBox(height: 16),

        // Interactive elements
        _buildInteractiveElements(context),
      ],
    );
  }

  Widget _buildLessonTypeIndicator() {
    IconData icon;
    Color color;
    String type;

    switch (lesson.type.name.toLowerCase()) {
      case 'video':
        icon = Icons.play_circle_outline;
        color = Colors.red;
        type = 'Video Lesson';
        break;
      case 'audio':
        icon = Icons.audiotrack;
        color = Colors.blue;
        type = 'Audio Lesson';
        break;
      case 'reading':
        icon = Icons.menu_book;
        color = Colors.green;
        type = 'Reading Lesson';
        break;
      case 'quiz':
        icon = Icons.quiz;
        color = Colors.orange;
        type = 'Quiz';
        break;
      default:
        icon = Icons.school;
        color = Colors.grey;
        type = 'Lesson';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            type,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (lesson.type.name.toLowerCase()) {
      case 'video':
        return _buildVideoContent();
      case 'audio':
        return _buildAudioContent();
      case 'reading':
        return _buildReadingContent();
      case 'quiz':
        return _buildQuizContent();
      default:
        return _buildDefaultContent();
    }
  }

  Widget _buildVideoContent() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video thumbnail or placeholder
          Icon(
            Icons.play_circle_outline,
            size: 64,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          // Play button overlay
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Implement video playback
                },
                borderRadius: BorderRadius.circular(8),
                child: const Center(
                  child: Icon(Icons.play_arrow, size: 48, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.audiotrack, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio Lesson',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${lesson.estimatedDuration} minutes',
                  style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement audio playback
            },
            icon: Icon(Icons.play_arrow, color: Colors.blue.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Material',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.description,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                'Quiz',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Test your knowledge with this quiz',
            style: TextStyle(color: Colors.orange.shade700),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to quiz
            },
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Start Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        lesson.description,
        style: TextStyle(color: Colors.grey.shade700, height: 1.5),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Text(
              lesson.isCompleted ? 'Completed' : 'In Progress',
              style: TextStyle(
                color: lesson.isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: lesson.isCompleted ? 1.0 : 0.0,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            lesson.isCompleted ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveElements(BuildContext context) {
    return Column(
      children: [
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: lesson.isCompleted
                    ? null
                    : () {
                        // TODO: Mark as completed
                      },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark Complete'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add to favorites
                },
                icon: const Icon(Icons.favorite_border),
                label: const Text('Favorite'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Additional info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Duration: ${lesson.estimatedDuration} minutes',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
