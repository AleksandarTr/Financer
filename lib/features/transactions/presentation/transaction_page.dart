import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../../../core/util/FixedPointHelper.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key, required this.title});
  final String title;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  Stream<List<Transaction>> getTransactions() {
    return AppDatabase.instance.transactions.all().watch();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          } else {
            final transactions = snapshot.data!;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  title: Text(transaction.name),
                  subtitle: Text('Amount: ${priceToString(transaction.baseAmount)}'),
                );
              },
            );
          }
        });
  }
}