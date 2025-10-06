import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../ai/presentation/viewmodels/ai_viewmodels.dart';

/// Translation View
class TranslationView extends StatefulWidget {
  const TranslationView({super.key});

  @override
  State<TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'en';

  final List<Map<String, String>> _supportedLanguages = [
    {'code': 'auto', 'name': 'Auto-detect'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'ewondo', 'name': 'Ewondo'},
    {'code': 'bafang', 'name': 'Bafang'},
    {'code': 'pidgin', 'name': 'Pidgin English'},
    {'code': 'duala', 'name': 'Duala'},
    {'code': 'fulfulde', 'name': 'Fulfulde'},
  ];

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _swapLanguages,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Implement translation history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Translation history coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final userId = authViewModel.currentUser?.id ?? 'guest_user';

          return Consumer<TranslationViewModel>(
            builder: (context, translationViewModel, child) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Language Selection
                    _buildLanguageSelection(),
                    const SizedBox(height: 16),

                    // Source Text Input
                    _buildSourceInput(),
                    const SizedBox(height: 16),

                    // Translate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _sourceController.text.isNotEmpty
                            ? () => _translateText(translationViewModel, userId)
                            : null,
                        icon: translationViewModel.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.translate),
                        label: Text(
                          translationViewModel.isLoading
                              ? 'Translating...'
                              : 'Translate',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target Text Output
                    _buildTargetOutput(translationViewModel),
                    const SizedBox(height: 16),

                    // Action Buttons
                    if (_targetController.text.isNotEmpty)
                      _buildActionButtons(translationViewModel, userId),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sourceLanguage,
                    decoration: const InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                    items: _supportedLanguages.map((lang) {
                      return DropdownMenuItem(
                        value: lang['code'],
                        child: Text(lang['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sourceLanguage = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _swapLanguages,
                  icon: const Icon(Icons.swap_horiz),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLanguage,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    items: _supportedLanguages
                        .where((lang) => lang['code'] != 'auto')
                        .map((lang) {
                          return DropdownMenuItem(
                            value: lang['code'],
                            child: Text(lang['name']!),
                          );
                        })
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _targetLanguage = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Text to translate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sourceController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Enter text to translate...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${_sourceController.text.length} characters',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _sourceController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetOutput(TranslationViewModel translationViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Translation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_targetController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      // TODO: Implement copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                translationViewModel.isLoading
                    ? 'Translating...'
                    : _targetController.text.isEmpty
                    ? 'Translation will appear here'
                    : _targetController.text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (translationViewModel.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  translationViewModel.error!,
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    TranslationViewModel translationViewModel,
    String userId,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement save translation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Translation saved')),
              );
            },
            icon: const Icon(Icons.bookmark_outline),
            label: const Text('Save'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement share translation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ),
      ],
    );
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      // Also swap the text content
      final tempText = _sourceController.text;
      _sourceController.text = _targetController.text;
      _targetController.text = tempText;
    });
  }

  void _translateText(
    TranslationViewModel translationViewModel,
    String userId,
  ) async {
    if (_sourceController.text.isEmpty) return;

    try {
      await translationViewModel.translate(
        userId: userId,
        sourceText: _sourceController.text,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );

      if (translationViewModel.currentTranslation != null) {
        setState(() {
          _targetController.text =
              translationViewModel.currentTranslation!.targetText;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Translation failed: $e')));
      }
    }
  }
}
