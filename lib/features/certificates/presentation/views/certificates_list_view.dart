import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/certificate_viewmodel.dart';
import '../../domain/entities/certificate_entity.dart';

/// Certificates list view for learners
class CertificatesListView extends StatefulWidget {
  final String userId;

  const CertificatesListView({super.key, required this.userId});

  @override
  State<CertificatesListView> createState() => _CertificatesListViewState();
}

class _CertificatesListViewState extends State<CertificatesListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CertificateViewModel>().loadUserCertificates(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Certificats'),
        backgroundColor: Colors.green,
      ),
      body: Consumer<CertificateViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Erreur: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        viewModel.loadUserCertificates(widget.userId),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.certificates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun certificat',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complétez des cours pour obtenir des certificats',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => viewModel.loadUserCertificates(widget.userId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatisticsCard(viewModel),
                const SizedBox(height: 24),
                Text(
                  'Certificats (${viewModel.totalCertificates})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...viewModel.certificates.map(
                  (cert) => _buildCertificateCard(cert, viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCard(CertificateViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              Icons.workspace_premium,
              'Total',
              '${viewModel.totalCertificates}',
              Colors.blue,
            ),
            _buildStatItem(
              Icons.check_circle,
              'Approuvés',
              '${viewModel.approvedCount}',
              Colors.green,
            ),
            _buildStatItem(
              Icons.pending,
              'En attente',
              '${viewModel.pendingApprovalCertificates.length}',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildCertificateCard(
    CertificateEntity certificate,
    CertificateViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showCertificateDetails(certificate),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        certificate.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: _getStatusColor(certificate.status),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          certificate.courseName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          certificate.languageName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(certificate.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.grade, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('Score: ${certificate.score}%'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, size: 16),
                      const SizedBox(width: 4),
                      Text('Niveau: ${certificate.level}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(_formatDate(certificate.issuedDate)),
                    ],
                  ),
                ],
              ),
              if (certificate.isApproved) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _downloadCertificate(certificate, viewModel),
                        icon: const Icon(Icons.download),
                        label: const Text('Télécharger'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareCertificate(certificate),
                        icon: const Icon(Icons.share),
                        label: const Text('Partager'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(CertificateStatus status) {
    String label;
    Color color;

    switch (status) {
      case CertificateStatus.pending:
        label = 'En attente';
        color = Colors.orange;
        break;
      case CertificateStatus.approved:
        label = 'Approuvé';
        color = Colors.green;
        break;
      case CertificateStatus.rejected:
        label = 'Rejeté';
        color = Colors.red;
        break;
      case CertificateStatus.revoked:
        label = 'Révoqué';
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  Color _getStatusColor(CertificateStatus status) {
    switch (status) {
      case CertificateStatus.pending:
        return Colors.orange;
      case CertificateStatus.approved:
        return Colors.green;
      case CertificateStatus.rejected:
        return Colors.red;
      case CertificateStatus.revoked:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCertificateDetails(CertificateEntity certificate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails du Certificat'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('N°: ${certificate.certificateNumber}'),
              const SizedBox(height: 8),
              Text('Cours: ${certificate.courseName}'),
              const SizedBox(height: 8),
              Text('Langue: ${certificate.languageName}'),
              const SizedBox(height: 8),
              Text('Score: ${certificate.score}%'),
              const SizedBox(height: 8),
              Text('Niveau: ${certificate.level}'),
              const SizedBox(height: 8),
              Text('Date d\'émission: ${_formatDate(certificate.issuedDate)}'),
              if (certificate.approvedDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Date d\'approbation: ${_formatDate(certificate.approvedDate!)}',
                ),
              ],
              if (certificate.verificationCode != null) ...[
                const SizedBox(height: 8),
                Text('Code de vérification: ${certificate.verificationCode}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _downloadCertificate(
    CertificateEntity certificate,
    CertificateViewModel viewModel,
  ) async {
    final result = await viewModel.downloadCertificate(certificate.id);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificat téléchargé avec succès')),
      );
    }
  }

  void _shareCertificate(CertificateEntity certificate) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Partage non implémenté')));
  }
}
