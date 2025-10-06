import 'package:flutter/material.dart';
import '../../domain/entities/culture_entities.dart';

/// Culture Content Detail View
class CultureContentDetailView extends StatelessWidget {
  final CultureContentEntity content;
  final ScrollController scrollController;

  const CultureContentDetailView({
    super.key,
    required this.content,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            children: [
              Expanded(
                child: Text(
                  content.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category chip
          Chip(
            label: Text(content.category.toString().split('.').last),
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ),

          const SizedBox(height: 16),

          // Image (if available)
          if (content.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                content.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 200),
              ),
            ),

          const SizedBox(height: 16),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 20),

                  // Main content
                  Text(
                    'Content',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 20),

                  // Tags
                  if (content.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: content.tags.map((tag) =>
                        Chip(
                          label: Text(tag),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Metadata
                  Text(
                    'Additional Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildMetadataSection(context, content.metadata),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context, Map<String, dynamic> metadata) {
    if (metadata.isEmpty) {
      return const Text('No additional information available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: metadata.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.key}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(entry.value.toString()),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Historical Content Detail View
class HistoricalContentDetailView extends StatelessWidget {
  final HistoricalContentEntity content;
  final ScrollController scrollController;

  const HistoricalContentDetailView({
    super.key,
    required this.content,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            children: [
              Expanded(
                child: Text(
                  content.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Period chip
          Chip(
            label: Text(content.period),
            backgroundColor: Colors.blue.withValues(alpha: 0.1),
          ),

          const SizedBox(height: 16),

          // Image (if available)
          if (content.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                content.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 200),
              ),
            ),

          const SizedBox(height: 16),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 20),

                  // Main content
                  Text(
                    'Historical Content',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 20),

                  // Historical details
                  if (content.eventDate != null || content.location != null) ...[
                    Text(
                      'Historical Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (content.eventDate != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Date: ${content.eventDate!.day}/${content.eventDate!.month}/${content.eventDate!.year}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    if (content.location != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Location: ${content.location}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: 20),

                  // Historical figures
                  if (content.figures.isNotEmpty) ...[
                    Text(
                      'Key Figures',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: content.figures.map((figure) =>
                        Chip(
                          label: Text(figure),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Sources
                  if (content.sources.isNotEmpty) ...[
                    Text(
                      'Sources',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...content.sources.map((source) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(source)),
                        ],
                      ),
                    )),
                  ],

                  const SizedBox(height: 20),

                  // Metadata
                  Text(
                    'Additional Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildMetadataSection(context, content.metadata),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context, Map<String, dynamic> metadata) {
    if (metadata.isEmpty) {
      return const Text('No additional information available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: metadata.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.key}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(entry.value.toString()),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Yemba Content Detail View
class YembaContentDetailView extends StatelessWidget {
  final YembaContentEntity content;
  final ScrollController scrollController;

  const YembaContentDetailView({
    super.key,
    required this.content,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            children: [
              Expanded(
                child: Text(
                  content.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category and difficulty chips
          Row(
            children: [
              Chip(
                label: Text(content.category.toString().split('.').last),
                backgroundColor: _getCategoryColor(content.category),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(content.difficulty),
                backgroundColor: _getDifficultyColor(content.difficulty).withValues(alpha: 0.1),
                labelStyle: TextStyle(color: _getDifficultyColor(content.difficulty)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Audio button (if available)
          if (content.audioUrl != null)
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement audio playback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio playback not yet implemented')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Audio'),
            ),

          const SizedBox(height: 16),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content
                  Text(
                    'Yemba Content',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      content.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Examples
                  if (content.examples.isNotEmpty) ...[
                    Text(
                      'Examples',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...content.examples.map((example) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(example),
                      ),
                    )),
                  ],

                  const SizedBox(height: 20),

                  // Translations
                  if (content.translations.isNotEmpty) ...[
                    Text(
                      'Translations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...content.translations.entries.map((translation) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              translation.key,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(Icons.arrow_forward),
                          Expanded(
                            child: Text(translation.value),
                          ),
                        ],
                      ),
                    )),
                  ],

                  const SizedBox(height: 20),

                  // Tags
                  if (content.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: content.tags.map((tag) =>
                        Chip(
                          label: Text(tag),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Metadata
                  Text(
                    'Additional Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          ),
                  ),
                  const SizedBox(height: 8),
                  _buildMetadataSection(context, content.metadata),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(YembaCategory category) {
    switch (category) {
      case YembaCategory.vocabulary:
        return Colors.green.withValues(alpha: 0.1);
      case YembaCategory.grammar:
        return Colors.blue.withValues(alpha: 0.1);
      case YembaCategory.pronunciation:
        return Colors.orange.withValues(alpha: 0.1);
      case YembaCategory.conversation:
        return Colors.purple.withValues(alpha: 0.1);
      case YembaCategory.culture:
        return Colors.red.withValues(alpha: 0.1);
      default:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMetadataSection(BuildContext context, Map<String, dynamic> metadata) {
    if (metadata.isEmpty) {
      return const Text('No additional information available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: metadata.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.key}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(entry.value.toString()),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}