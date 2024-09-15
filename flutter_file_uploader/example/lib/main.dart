import 'package:example/examples/examples.dart';
import 'package:example/l10n/l10n.dart';
import 'package:example/settings/model.dart';
import 'package:example/settings/ui.dart';
import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  backend.clear();
  runApp(const App());
}

final _routes = <String, Widget Function(BuildContext)>{
  '/default': (_) => DefaultFilesUpload(),
  '/default_restorable_chunked': (_) => DefaultRestorableChunkedFilesUpload(),
  './self_ref_management': (_) => SelfRefManagementFilesUpload(),
};

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExampleSettings(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {'/': (_) => ShowCase(), ..._routes},
      ),
    );
  }
}

class ShowCase extends StatelessWidget {
  const ShowCase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SHOW CASE'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: _routes.keys.map((name) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, name);
                    },
                    child: Text(name),
                  );
                }).toList(),
              ),
            ),
            SettingsConsumer(),
          ],
        ),
      ),
    );
  }
}
