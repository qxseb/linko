import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'router.dart';
import 'utils/theme.dart';

void main() {
  runApp(const LinkOApp());
}

class LinkOApp extends StatelessWidget {
  const LinkOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Builder(
        builder: (context) {
          final appState = Provider.of<AppState>(context);
          if (!appState.isInitialized) {
            return MaterialApp(
              title: 'LinkO',
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MaterialApp.router(
            title: 'LinkO',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
