import 'dart:io';

import 'package:financer/features/currencies/data/frankfurter_api.dart';
import 'package:financer/features/transactions/presentation/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:financer/generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const title = "Financer";

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(800, 600), // Prevent resizing below this
    center: true,
    title: title,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true);
  });

  windowManager.addListener(GlobalWindowListener());

  runApp(const MyApp(title: title,));
}

class GlobalWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    exit(0);
  }
}

class MyApp extends StatelessWidget {
  final String title;

  const MyApp({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();
    FrankfurterApi().fetchExchangeRates(DateTime.now(), "EUR");

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan,
        brightness: Brightness.light,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
    );

    return MaterialApp(
      title: title,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (navigatorKey.currentState!.canPop()) {
                      navigatorKey.currentState?.pop(context);
                    }
                  },
                );
              },
            ),
          ),
          body: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                final canGoBack = navigatorKey.currentState?.canPop() ?? false;
                if (canGoBack) {
                  navigatorKey.currentState?.pop();
                }
              },
              child: Navigator(
                key: navigatorKey,
                onGenerateRoute: (RouteSettings settings) {
                  return MaterialPageRoute(
                    builder: (context) => HomePage(title: title),
                  );
                },
              )
          )
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;

  static const IconData attachMoneySharp = IconData(
      0xe7b0, fontFamily: 'MaterialIcons');
  static const IconData accountBalanceSharp = IconData(
      0xe740, fontFamily: 'MaterialIcons');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: _currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(attachMoneySharp),
            label: l10n.transactions,
          ),
          NavigationDestination(
            icon: Icon(accountBalanceSharp),
            label: l10n.accounts,
          )
        ],
      ),
      body: <Widget>[
        TransactionPage(title: widget.title),
        Container(color: theme.colorScheme.primaryContainer)
      ][_currentPageIndex],
    );
  }
}