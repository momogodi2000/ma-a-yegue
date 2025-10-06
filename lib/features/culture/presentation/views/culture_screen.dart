import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/common/loading_widget.dart';
import '../../../../shared/widgets/common/error_widget.dart' as custom_error;
import '../viewmodels/culture_viewmodels.dart';
import '../widgets/culture_content_cards.dart';

/// Main Culture Screen
class CultureScreen extends StatefulWidget {
  const CultureScreen({super.key});

  @override
  State<CultureScreen> createState() => _CultureScreenState();
}

class _CultureScreenState extends State<CultureScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final cultureVM = context.read<CultureViewModel>();
    final historicalVM = context.read<HistoricalViewModel>();
    final yembaVM = context.read<YembaViewModel>();

    await Future.wait([
      cultureVM.loadCultureContent(),
      historicalVM.loadHistoricalContent(),
      yembaVM.loadYembaContent(),
      cultureVM.loadStatistics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Culture & History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Culture'),
            Tab(text: 'History'),
            Tab(text: 'Yemba'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CultureContentTab(),
          HistoricalContentTab(),
          YembaContentTab(),
        ],
      ),
    );
  }
}

/// Culture Content Tab
class CultureContentTab extends StatelessWidget {
  const CultureContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CultureViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingWidget();
        }

        if (viewModel.error != null) {
          return custom_error.ErrorWidget(
            title: 'Error Loading Culture Content',
            message: viewModel.error,
            onRetry: () => viewModel.loadCultureContent(),
          );
        }

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: viewModel.searchCultureContent,
                decoration: InputDecoration(
                  hintText: 'Search culture content...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: viewModel.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: viewModel.clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Statistics
            if (viewModel.statistics.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      title: 'Culture Items',
                      value: viewModel.statistics['culture_content']?.toString() ?? '0',
                      icon: Icons.library_books,
                    ),
                  ],
                ),
              ),

            // Content list
            Expanded(
              child: viewModel.filteredCultureContent.isEmpty
                  ? const Center(child: Text('No culture content found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.filteredCultureContent.length,
                      itemBuilder: (context, index) {
                        final content = viewModel.filteredCultureContent[index];
                        return CultureContentCard(content: content);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Historical Content Tab
class HistoricalContentTab extends StatelessWidget {
  const HistoricalContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoricalViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingWidget();
        }

        if (viewModel.error != null) {
          return custom_error.ErrorWidget(
            title: 'Error Loading Historical Content',
            message: viewModel.error,
            onRetry: () => viewModel.loadHistoricalContent(),
          );
        }

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: viewModel.searchHistoricalContent,
                decoration: InputDecoration(
                  hintText: 'Search historical content...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: viewModel.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: viewModel.clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Content list
            Expanded(
              child: viewModel.filteredHistoricalContent.isEmpty
                  ? const Center(child: Text('No historical content found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.filteredHistoricalContent.length,
                      itemBuilder: (context, index) {
                        final content = viewModel.filteredHistoricalContent[index];
                        return HistoricalContentCard(content: content);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Yemba Content Tab
class YembaContentTab extends StatelessWidget {
  const YembaContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<YembaViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingWidget();
        }

        if (viewModel.error != null) {
          return custom_error.ErrorWidget(
            title: 'Error Loading Yemba Content',
            message: viewModel.error,
            onRetry: () => viewModel.loadYembaContent(),
          );
        }

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: viewModel.searchYembaContent,
                decoration: InputDecoration(
                  hintText: 'Search Yemba content...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: viewModel.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: viewModel.clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Content list
            Expanded(
              child: viewModel.filteredYembaContent.isEmpty
                  ? const Center(child: Text('No Yemba content found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.filteredYembaContent.length,
                      itemBuilder: (context, index) {
                        final content = viewModel.filteredYembaContent[index];
                        return YembaContentCard(content: content);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Statistics Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}