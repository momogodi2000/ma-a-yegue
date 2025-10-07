import 'package:flutter/material.dart';
import 'package:maa_yegue/features/lessons/domain/entities/lesson.dart';
import 'package:maa_yegue/features/lessons/domain/entities/lesson_content.dart';
import 'package:maa_yegue/features/lessons/data/services/progress_tracking_service.dart';

/// Main lesson player view that handles different content types
class LessonPlayerView extends StatefulWidget {
  final Lesson lesson;
  final String languageCode;
  final ProgressTrackingService progressService;
  final VoidCallback? onLessonCompleted;
  final VoidCallback? onBackPressed;

  const LessonPlayerView({
    Key? key,
    required this.lesson,
    required this.languageCode,
    required this.progressService,
    this.onLessonCompleted,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<LessonPlayerView> createState() => _LessonPlayerViewState();
}

class _LessonPlayerViewState extends State<LessonPlayerView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentContentIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Progress tracking
  final Map<String, Duration> _contentWatchTime = {};
  bool _lessonCompleted = false;

  // Animation
  late AnimationController _progressAnimation;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimation, curve: Curves.easeInOut),
    );

    _updateProgressAnimation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimation.dispose();
    super.dispose();
  }

  void _updateProgressAnimation() {
    if (widget.lesson.contents.isNotEmpty) {
      final progress =
          (_currentContentIndex + 1) / widget.lesson.contents.length;
      _progressValue = Tween<double>(begin: _progressValue.value, end: progress)
          .animate(
            CurvedAnimation(
              parent: _progressAnimation,
              curve: Curves.easeInOut,
            ),
          );
      _progressAnimation.forward(from: 0.0);
    }
  }

  void _onContentCompleted(String contentId, Duration watchTime) {
    _contentWatchTime[contentId] = watchTime;

    // Auto-advance to next content after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_lessonCompleted) {
        _nextContent();
      }
    });
  }

  void _nextContent() {
    if (_currentContentIndex < widget.lesson.contents.length - 1) {
      setState(() {
        _currentContentIndex++;
      });
      _pageController.animateToPage(
        _currentContentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgressAnimation();
    } else {
      _completeLesson();
    }
  }

  void _previousContent() {
    if (_currentContentIndex > 0) {
      setState(() {
        _currentContentIndex--;
      });
      _pageController.animateToPage(
        _currentContentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgressAnimation();
    }
  }

  Future<void> _completeLesson() async {
    if (_lessonCompleted) return;

    setState(() {
      _isLoading = true;
      _lessonCompleted = true;
    });

    try {
      // Calculate total watch time
      final totalWatchTime = _contentWatchTime.values.fold(
        Duration.zero,
        (total, time) => total + time,
      );

      // Update progress tracking
      await widget.progressService.updateLessonProgress(
        userId: 'current_user', // TODO: Get from auth
        lessonId: widget.lesson.id,
        languageCode: widget.languageCode,
        progressPercentage: 100,
        timeSpentSeconds: totalWatchTime.inSeconds,
      );

      // Update skill progress based on lesson type
      await widget.progressService.updateSkillProgress(
        userId: 'current_user',
        languageCode: widget.languageCode,
        skillName: _getSkillNameForLesson(),
        proficiencyScore: _calculateProficiencyScore(totalWatchTime).toInt(),
      );

      // Check for milestones (this is called internally by updateLessonProgress)

      setState(() => _isLoading = false);

      // Show completion dialog
      _showCompletionDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error completing lesson: $e';
      });
    }
  }

  String _getSkillNameForLesson() {
    // Map lesson types to skills
    switch (widget.lesson.type) {
      case LessonType.vocabulary:
        return 'vocabulary';
      case LessonType.grammar:
        return 'grammar';
      case LessonType.pronunciation:
        return 'pronunciation';
      case LessonType.conversation:
        return 'conversation';
      case LessonType.culture:
        return 'cultural';
      default:
        return 'general';
    }
  }

  double _calculateProficiencyScore(Duration totalWatchTime) {
    // Base score on watch time and lesson completion
    const baseScore = 10.0;
    final timeBonus =
        (totalWatchTime.inMinutes / widget.lesson.estimatedDuration) * 5.0;
    return (baseScore + timeBonus).clamp(0.0, 20.0);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Lesson Completed! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Great job completing "${widget.lesson.title}"!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve earned experience points and improved your ${_getSkillNameForLesson()} skills.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onLessonCompleted?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
        ),
        actions: [
          // Progress indicator
          Container(
            width: 60,
            height: 8,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progressValue.value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Content area
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              itemCount: widget.lesson.contents.length,
              onPageChanged: (index) {
                setState(() => _currentContentIndex = index);
                _updateProgressAnimation();
              },
              itemBuilder: (context, index) {
                final content = widget.lesson.contents[index];
                return _buildContentWidget(content);
              },
            ),
          ),

          // Navigation controls
          if (!_lessonCompleted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  ElevatedButton.icon(
                    onPressed: _currentContentIndex > 0
                        ? _previousContent
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                  ),

                  // Progress text
                  Text(
                    '${_currentContentIndex + 1} / ${widget.lesson.contents.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // Next button
                  ElevatedButton.icon(
                    onPressed: _nextContent,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red[400]),
                    onPressed: () => setState(() => _errorMessage = null),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentWidget(LessonContent content) {
    switch (content.type) {
      case ContentType.video:
        return _buildVideoContent(content);
      case ContentType.audio:
        return _buildAudioContent(content);
      case ContentType.text:
        return _buildTextContent(content);
      case ContentType.image:
        return _buildImageContent(content);
      default:
        return _buildTextContent(content); // Fallback to text
    }
  }

  Widget _buildVideoContent(LessonContent content) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, size: 64, color: Colors.blue[300]),
          const SizedBox(height: 20),
          const Text(
            'Video Content',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content.content,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () =>
                _onContentCompleted(content.id, const Duration(seconds: 30)),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Mark as Watched'),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioContent(LessonContent content) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.audiotrack, size: 64, color: Colors.green[300]),
          const SizedBox(height: 20),
          const Text(
            'Audio Content',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content.content,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () =>
                _onContentCompleted(content.id, const Duration(seconds: 20)),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Mark as Listened'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(LessonContent content) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.text_fields, size: 64, color: Colors.orange[300]),
          const SizedBox(height: 20),
          const Text(
            'Text Content',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                content.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () =>
                _onContentCompleted(content.id, const Duration(seconds: 15)),
            icon: const Icon(Icons.check),
            label: const Text('Mark as Read'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(LessonContent content) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image display
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: content.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(content.imageUrl!),
                        fit: BoxFit.contain,
                      )
                    : null,
                color: Colors.grey[200],
              ),
              child: content.imageUrl == null
                  ? Icon(Icons.image, size: 64, color: Colors.grey[400])
                  : null,
            ),
          ),

          const SizedBox(height: 20),

          // Content text
          Text(
            content.content,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () =>
                _onContentCompleted(content.id, const Duration(seconds: 10)),
            icon: const Icon(Icons.visibility),
            label: const Text('Mark as Viewed'),
          ),
        ],
      ),
    );
  }
}
