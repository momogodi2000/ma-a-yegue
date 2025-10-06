import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

/// Widget for switching between app languages (French/English)
class LanguageSwitcherWidget extends StatelessWidget {
  final bool showAsDialog;
  final VoidCallback? onLanguageChanged;

  const LanguageSwitcherWidget({
    super.key,
    this.showAsDialog = false,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final currentLocale = localeProvider.locale;

        if (showAsDialog) {
          return _buildDialogContent(context, localeProvider, currentLocale);
        } else {
          return _buildInlineContent(context, localeProvider, currentLocale);
        }
      },
    );
  }

  Widget _buildInlineContent(
    BuildContext context,
    LocaleProvider localeProvider,
    Locale currentLocale,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(AppLocalizations.of(context)?.language ?? 'Language'),
        subtitle: Text(_getLanguageName(currentLocale.languageCode)),
        trailing: DropdownButton<Locale>(
          value: currentLocale,
          underline: const SizedBox.shrink(),
          items: const [
            DropdownMenuItem(
              value: Locale('fr'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('🇫🇷'), SizedBox(width: 8), Text('Français')],
              ),
            ),
            DropdownMenuItem(
              value: Locale('en'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('🇬🇧'), SizedBox(width: 8), Text('English')],
              ),
            ),
          ],
          onChanged: (Locale? newLocale) {
            if (newLocale != null && newLocale != currentLocale) {
              localeProvider.setLocale(newLocale);
              onLanguageChanged?.call();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDialogContent(
    BuildContext context,
    LocaleProvider localeProvider,
    Locale currentLocale,
  ) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)?.language ?? 'Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            context,
            localeProvider,
            const Locale('fr'),
            '🇫🇷',
            'Français',
            currentLocale,
          ),
          const SizedBox(height: 16),
          _buildLanguageOption(
            context,
            localeProvider,
            const Locale('en'),
            '🇬🇧',
            'English',
            currentLocale,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LocaleProvider localeProvider,
    Locale locale,
    String flag,
    String name,
    Locale currentLocale,
  ) {
    final isSelected = locale.languageCode == currentLocale.languageCode;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : null,
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : null,
        onTap: () {
          if (!isSelected) {
            localeProvider.setLocale(locale);
            onLanguageChanged?.call();
            if (showAsDialog) {
              Navigator.of(context).pop();
            }
          }
        },
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return languageCode.toUpperCase();
    }
  }
}

/// Floating action button for quick language switching
class LanguageSwitcherFAB extends StatelessWidget {
  const LanguageSwitcherFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) =>
              const LanguageSwitcherWidget(showAsDialog: true),
        );
      },
      mini: true,
      child: const Icon(Icons.language),
    );
  }
}

/// Simple language toggle button
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final currentLocale = localeProvider.locale;
        final isFrench = currentLocale.languageCode == 'fr';

        return IconButton(
          onPressed: () {
            localeProvider.toggleLocale();
          },
          icon: Text(
            isFrench ? '🇬🇧' : '🇫🇷',
            style: const TextStyle(fontSize: 20),
          ),
          tooltip: isFrench ? 'Switch to English' : 'Passer au français',
        );
      },
    );
  }
}
