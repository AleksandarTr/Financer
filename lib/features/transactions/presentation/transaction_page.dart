import 'package:drift/drift.dart';
import 'package:financer/features/transactions/presentation/new_transaction_page.dart';
import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../../../core/widgets/infinite_list_view.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key, required this.title});
  final String title;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  Future<List<Transaction>> getTransactionsPaged(int limit, int offset) {
    return (AppDatabase.instance.transactions.select()
      ..orderBy(
          [(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])
      ..limit(limit, offset: offset))
        .get();
  }

  Widget _buildTransactionList() {
    return Scaffold(
      body: InfiniteListView<Transaction>(
        pageSize: 20,
        loader: getTransactionsPaged,
        itemBuilder: (context, transaction) => ListTile(
          title: Text(transaction.name),
          trailing: Text("${transaction.baseAmount / 100} RSD"),
        ),
      ),
      floatingActionButton: _buildNewTransactionButton(),
    );
  }

  Widget _buildNewTransactionButton() {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NewTransactionPage()
            )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTransactionList();
  }
}