import 'package:drift/drift.dart' hide Column;
import 'package:financer/features/transactions/presentation/transaction_page.dart';
import 'package:flutter/material.dart';

import 'core/database/database.dart';
import 'features/transactions/domain/transaction_message_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(title: 'Financer'),
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

  static const IconData attachMoneySharp = IconData(0xe7b0, fontFamily: 'MaterialIcons');
  static const IconData accountBalanceSharp = IconData(0xe740, fontFamily: 'MaterialIcons');

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