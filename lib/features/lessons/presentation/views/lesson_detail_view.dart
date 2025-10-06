import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/lesson_viewmodel.dart';
import '../widgets/lesson_content_widget.dart';
import '../widgets/lesson_progress_widget.dart';

/// Lesson Detail View
class LessonDetailView extends StatefulWidget {
  final String lessonId;

  const LessonDetailView({super.key, required this.lessonId});

  @override
  State<LessonDetailView> createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends State<LessonDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonViewModel>().getLessonById(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson'),
        actions: [
          Consumer<LessonViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.currentLesson != null) {
                return IconButton(
                  icon: const Icon(Icons.bookmark_outline),
                  onPressed: () {
                    // TODO: Implement bookmark functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bookmark feature coming soon'),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<LessonViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading lesson',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.getLessonById(widget.lessonId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.currentLesson == null) {
            return const Center(child: Text('Lesson not found'));
          }

          final lesson = viewModel.currentLesson!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lesson.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoChip(
                              icon: Icons.access_time,
                              label: '${lesson.estimatedDuration} min',
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              icon: Icons.school,
                              label: lesson.type.name.toUpperCase(),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(lesson.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Section
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    final userId = authViewModel.currentUser?.id;
                    if (userId != null) {
                      return LessonProgressWidget(
                        lesson: lesson,
                        userId: userId,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),

                // Lesson Content
                LessonContentWidget(lesson: lesson),
                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(context, lesson),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(dynamic status) {
    Color color;
    String label;

    switch (status.toString()) {
      case 'LessonStatus.locked':
        color = Colors.grey;
        label = 'Locked';
        break;
      case 'LessonStatus.available':
        color = Colors.blue;
        label = 'Available';
        break;
      case 'LessonStatus.inProgress':
        color = Colors.orange;
        label = 'In Progress';
        break;
      case 'LessonStatus.completed':
        color = Colors.green;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Chip(
      backgroundColor: color.withValues(alpha: 0.1),
      label: Text(label, style: TextStyle(color: color)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic lesson) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement start lesson functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting lesson...')),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Lesson'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement practice mode
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Practice mode coming soon')),
              );
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text('Practice'),
          ),
        ),
      ],
    );
  }
}
