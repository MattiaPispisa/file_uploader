import 'package:flutter/material.dart';
import 'package:flutter_file_uploader_example/l10n/l10n.dart';
import 'package:flutter_file_uploader_example/settings/model.dart';
import 'package:provider/provider.dart';

class SettingsConsumer extends StatelessWidget {
  const SettingsConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Upload Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _LimitTile(),
          Divider(height: 1),
          _HideOnLimitTile(),
          Divider(height: 1),
          _ColorTile(),
          Divider(height: 1),
          _LocaleTile(),
        ],
      ),
    );
  }
}

class _LimitTile extends StatelessWidget {
  const _LimitTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ExampleSettings, int?>(
      selector: (_, state) => state.limit,
      builder: (context, limit, child) {
        return ListTile(
          title: const Text('File limit'),
          subtitle: const Text('Maximum files allowed'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: context.read<ExampleSettings>().canDecrementLimit
                    ? () => context.read<ExampleSettings>().decrementLimit()
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  limit?.toString() ?? '∞',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: context.read<ExampleSettings>().canIncrementLimit
                    ? () => context.read<ExampleSettings>().incrementLimit()
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              _ResetToDefaultButton(
                onPressed: limit != null
                    ? () => context.read<ExampleSettings>().limit = null
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HideOnLimitTile extends StatelessWidget {
  const _HideOnLimitTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ExampleSettings, bool?>(
      selector: (_, state) => state.hideOnLimit,
      builder: (context, hideOnLimit, child) {
        return SwitchListTile.adaptive(
          title: const Text('Hide on limit'),
          subtitle: const Text('Hide upload button when limit is reached'),
          value: hideOnLimit ?? false,
          onChanged: (_) {
            context.read<ExampleSettings>().toggleHideOnLimit();
          },
        );
      },
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ExampleSettings, Color?>(
      selector: (_, state) => state.color,
      builder: (context, color, child) {
        final hasCustomColor = color != null;

        return ListTile(
          title: const Text('Theme Color'),
          subtitle: const Text('Customize the uploader accent'),
          leading: Container(
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
              ),
            ),
            height: 40,
            width: 40,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () => context.read<ExampleSettings>().randomColor(),
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text("Random"),
              ),
              _ResetToDefaultButton(
                onPressed: hasCustomColor
                    ? () => context.read<ExampleSettings>().color = null
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResetToDefaultButton extends StatelessWidget {
  const _ResetToDefaultButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.restore),
      tooltip: 'Reset to default',
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ExampleSettings, Locale?>(
      selector: (_, state) => state.locale,
      builder: (context, locale, child) {
        final currentLocale = locale ?? const Locale('en');

        return ListTile(
          title: Text(context.t().languageTitle),
          subtitle: Text(context.t().languageSubtitle),
          trailing: DropdownButton<Locale>(
            value: currentLocale,
            underline: const SizedBox(),
            onChanged: (newLocale) {
              if (newLocale != null) {
                context.read<ExampleSettings>().locale = newLocale;
              }
            },
            items: [
              DropdownMenuItem(
                value: Locale('en'),
                child: Text(context.t().englishOption),
              ),
              DropdownMenuItem(
                value: Locale('it'),
                child: Text(context.t().italianOption),
              ),
            ],
          ),
        );
      },
    );
  }
}
