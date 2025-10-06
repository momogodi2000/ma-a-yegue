import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/ai_viewmodels.dart';
import '../widgets/ai_widgets.dart';
import '../widgets/ai_additional_widgets.dart';

class IaPage extends StatefulWidget {
  const IaPage({super.key});

  @override
  State<IaPage> createState() => _IaPageState();
}

class _IaPageState extends State<IaPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IA Assistant"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Chat', icon: Icon(Icons.chat)),
            Tab(text: 'Translate', icon: Icon(Icons.translate)),
            Tab(text: 'Pronunciation', icon: Icon(Icons.mic)),
            Tab(text: 'Generate', icon: Icon(Icons.create)),
            Tab(text: 'Recommendations', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const AiChatWidget(),
          const TranslationWidget(),
          const PronunciationAssessmentWidget(),
          const ContentGenerationWidget(),
          _buildAiRecommendationsWidget(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    return _tabController.index == 0
        ? FloatingActionButton(
            onPressed: () => _startNewConversation(context),
            tooltip: 'New Conversation',
            child: const Icon(Icons.add),
          )
        : null;
  }

  void _startNewConversation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Conversation'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Conversation Title',
            hintText: 'Enter a title for your conversation',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Get title from text field and user ID from auth
              final title = _titleController.text.trim().isEmpty
                  ? 'New Conversation'
                  : _titleController.text.trim();

              final authViewModel = context.read<AuthViewModel>();
              final userId = authViewModel.currentUser?.id ?? 'guest_user';

              context
                  .read<AiChatViewModel>()
                  .createNewConversation(userId, title);

              _titleController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendationsWidget() {
    return const AIRecommendationsWidget();
  }
}
