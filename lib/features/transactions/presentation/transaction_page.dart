import 'package:drift/drift.dart';
import 'package:financer/features/transactions/presentation/new_transaction_page.dart';
import 'package:financer/features/transactions/presentation/transaction_widget.dart';
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
  SimpleSelectStatement getTransactionsPaged() {
    return AppDatabase.instance.transactions.select()
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
  }

  Widget _buildTransactionList() {
    return Scaffold(
      body: InfiniteListView<Transaction>(
        pageSize: 20,
        loader: getTransactionsPaged,
        itemBuilder: (context, transaction) => TransactionWidget(transaction: transaction),
      ),
      floatingActionButton: _buildNewTransactionButton(),
    );
  }

  Widget _buildNewTransactionButton() {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const NewTransactionPage()),
        );
        setState(() {});
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 2))
        ),
        child: _buildTransactionList()
    );
  }
}