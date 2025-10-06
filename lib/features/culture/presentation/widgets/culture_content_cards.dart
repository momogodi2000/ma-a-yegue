import 'package:flutter/material.dart';
import '../../domain/entities/culture_entities.dart';
import '../views/culture_detail_views.dart';

/// Culture Content Card
class CultureContentCard extends StatelessWidget {
  final CultureContentEntity content;

  const CultureContentCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showCultureContentDetail(context, content),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (if available)
              if (content.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    content.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 150),
                  ),
                ),

              const SizedBox(height: 12),

              // Title
              Text(
                content.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                content.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Category and tags
              Row(
                children: [
                  Chip(
                    label: Text(content.category.toString().split('.').last),
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 8),
                  if (content.tags.isNotEmpty)
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: content.tags.take(3).map((tag) =>
                          Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 12)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          ),
                        ).toList(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCultureContentDetail(BuildContext context, CultureContentEntity content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, scrollController) => CultureContentDetailView(
          content: content,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

/// Historical Content Card
class HistoricalContentCard extends StatelessWidget {
  final HistoricalContentEntity content;

  const HistoricalContentCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showHistoricalContentDetail(context, content),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (if available)
              if (content.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    content.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 150),
                  ),
                ),

              const SizedBox(height: 12),

              // Title and period
              Row(
                children: [
                  Expanded(
                    child: Text(
                      content.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Chip(
                    label: Text(content.period),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                content.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Location and date
              if (content.location != null || content.eventDate != null)
                Row(
                  children: [
                    if (content.location != null) ...[
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(content.location!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                    if (content.eventDate != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${content.eventDate!.day}/${content.eventDate!.month}/${content.eventDate!.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),

              const SizedBox(height: 8),

              // Historical figures
              if (content.figures.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: content.figures.take(3).map((figure) =>
                    Chip(
                      label: Text(figure, style: const TextStyle(fontSize: 12)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
                  ).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoricalContentDetail(BuildContext context, HistoricalContentEntity content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, scrollController) => HistoricalContentDetailView(
          content: content,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

/// Yemba Content Card
class YembaContentCard extends StatelessWidget {
  final YembaContentEntity content;

  const YembaContentCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showYembaContentDetail(context, content),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and category
              Row(
                children: [
                  Expanded(
                    child: Text(
                      content.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Chip(
                    label: Text(content.category.toString().split('.').last),
                    backgroundColor: _getCategoryColor(content.category),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Content preview
              Text(
                content.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Difficulty and examples count
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: _getDifficultyColor(content.difficulty),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    content.difficulty,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getDifficultyColor(content.difficulty),
                        ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${content.examples.length} examples',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Tags
              if (content.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: content.tags.take(3).map((tag) =>
                    Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
                  ).toList(),
                ),
            ],
          ),
        ),
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

  void _showYembaContentDetail(BuildContext context, YembaContentEntity content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, scrollController) => YembaContentDetailView(
          content: content,
          scrollController: scrollController,
        ),
      ),
    );
  }
}