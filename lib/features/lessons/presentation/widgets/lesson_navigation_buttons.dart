import 'package:flutter/material.dart';
import '../../domain/entities/lesson.dart';

/// Widget for lesson navigation buttons
class LessonNavigationButtons extends StatelessWidget {
  final Lesson currentLesson;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const LessonNavigationButtons({
    super.key,
    required this.currentLesson,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Mark as complete button
            Expanded(
              flex: 2,
              child: currentLesson.isCompleted
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        _showMarkCompleteDialog(context);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ),

            const SizedBox(width: 16),

            // Next button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Complete'),
        content: const Text(
          'Are you sure you want to mark this lesson as complete? You can always come back to review it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement mark as complete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lesson marked as complete!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }
}
