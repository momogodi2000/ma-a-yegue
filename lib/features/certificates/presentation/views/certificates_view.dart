import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';

/// Certificates View
class CertificatesView extends StatefulWidget {
  const CertificatesView({super.key});

  @override
  State<CertificatesView> createState() => _CertificatesViewState();
}

class _CertificatesViewState extends State<CertificatesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download all certificates
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final userId = authViewModel.currentUser?.id;

          if (userId == null) {
            return const Center(
              child: Text('Please log in to view your certificates'),
            );
          }

          return _buildCertificatesList();
        },
      ),
    );
  }

  Widget _buildCertificatesList() {
    // Mock data - replace with actual data from your backend
    final mockCertificates = [
      {
        'id': '1',
        'title': 'Ewondo Language Basics',
        'description':
            'Certificate of completion for Ewondo language basics course',
        'date': '2024-01-15',
        'score': 95,
        'level': 'Beginner',
        'language': 'Ewondo',
        'isDownloaded': true,
      },
      {
        'id': '2',
        'title': 'Duala Conversation Skills',
        'description':
            'Certificate of completion for Duala conversation skills',
        'date': '2024-02-20',
        'score': 88,
        'level': 'Intermediate',
        'language': 'Duala',
        'isDownloaded': false,
      },
      {
        'id': '3',
        'title': 'Cameroonian Culture Awareness',
        'description':
            'Certificate of completion for Cameroonian culture awareness course',
        'date': '2024-03-10',
        'score': 92,
        'level': 'Beginner',
        'language': 'Multiple',
        'isDownloaded': true,
      },
    ];

    if (mockCertificates.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockCertificates.length,
      itemBuilder: (context, index) {
        final certificate = mockCertificates[index];
        return _buildCertificateCard(certificate);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Certificates Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete courses to earn certificates',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to lessons/courses
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.school),
            label: const Text('Start Learning'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> certificate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.school,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate['title'],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certificate['description'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (certificate['isDownloaded'])
                  Icon(
                    Icons.download_done,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: certificate['date'],
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.grade,
                  label: '${certificate['score']}%',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.trending_up,
                  label: certificate['level'],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _viewCertificate(certificate);
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _downloadCertificate(certificate);
                    },
                    icon: Icon(
                      certificate['isDownloaded']
                          ? Icons.download_done
                          : Icons.download,
                      size: 16,
                    ),
                    label: Text(
                      certificate['isDownloaded'] ? 'Downloaded' : 'Download',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _viewCertificate(Map<String, dynamic> certificate) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      certificate['title'],
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Certificate Preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Certificate preview will be implemented here',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _downloadCertificate(certificate);
                      },
                      child: const Text('Download'),
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

  void _downloadCertificate(Map<String, dynamic> certificate) {
    // TODO: Implement actual certificate download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${certificate['title']}...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _viewCertificate(certificate),
        ),
      ),
    );
  }
}
