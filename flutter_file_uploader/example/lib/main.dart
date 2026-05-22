import 'package:flutter/material.dart';
import 'package:flutter_file_uploader_example/examples/examples.dart';
import 'package:flutter_file_uploader_example/l10n/arb/app_localizations.dart';
import 'package:flutter_file_uploader_example/settings/model.dart';
import 'package:flutter_file_uploader_example/settings/ui.dart';
import 'package:flutter_file_uploader_example/utils.dart';
import 'package:provider/provider.dart';

void main() {
  backend.clear();
  runApp(const App());
}

final _routes = <String, Widget Function(BuildContext)>{
  '/default': (_) => DefaultFilesUpload(),
  '/default_restorable_chunked': (_) => DefaultRestorableChunkedFilesUpload(),
  './self_ref_management': (_) => SelfRefManagementFilesUpload(),
  './transformers': (_) => TransformersFilesUpload(),
  './complete': (_) => CompleteUploadExample(),
};

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExampleSettings(),
      child: Consumer<ExampleSettings>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: settings.locale,
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              useMaterial3: true,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routes: {'/': (_) => ShowCase(), ..._routes},
          );
        },
      ),
    );
  }
}

class ShowCase extends StatelessWidget {
  const ShowCase({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = _routes.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('SHOW CASE'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: routes.length,
                separatorBuilder: (context, index) => SizedBox(height: 8),
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final route = routes[index];

                  return _ShowCaseCard(
                    title: route.key,
                    onTap: () {
                      Navigator.pushNamed(context, route.key);
                    },
                  );
                },
              ),
            ),
            SettingsConsumer(),
          ],
        ),
      ),
    );
  }
}

class _ShowCaseCard extends StatelessWidget {
  const _ShowCaseCard({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.widgets_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
