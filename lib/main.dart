import 'package:financer/features/transactions/presentation/transaction_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Financer';
    final navigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.cyan),
      ),
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
                    builder: (context) => const HomePage(title: title),
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
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: _currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(attachMoneySharp),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(accountBalanceSharp),
            label: 'Accounts',
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