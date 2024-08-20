import 'package:example/examples/examples.dart';
import 'package:example/l10n/l10n.dart';
import 'package:example/utils.dart';
import 'package:flutter/material.dart';

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
    return MaterialApp(
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
    );
  }
}

class ShowCase extends StatelessWidget {
  const ShowCase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
    );
  }
}
