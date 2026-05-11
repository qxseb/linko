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

          if (appState.initializationError != null) {
            return MaterialApp(
              title: 'LinkO',
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appState.initializationError!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => appState.retryInitialization(),
                            child: const Text('Retry Live Backend'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => appState.enterDemoMode(),
                            child: const Text('Enter Demo Mode (Offline)'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return MaterialApp.router(
            title: 'LinkO',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return Column(
                children: [
                  _ModeStatusStrip(appState: appState),
                  Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ModeStatusStrip extends StatelessWidget {
  final AppState appState;

  const _ModeStatusStrip({required this.appState});

  @override
  Widget build(BuildContext context) {
    final isDemo = appState.isDemoMode;
    final background =
        isDemo ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0);
    final textColor =
        isDemo ? const Color(0xFF92400E) : const Color(0xFF065F46);
    final label = isDemo ? 'Demo Mode / Offline' : 'Live Backend';
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, topInset + 5, 12, 6),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          bottom: BorderSide(color: textColor.withValues(alpha: 0.18)),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
