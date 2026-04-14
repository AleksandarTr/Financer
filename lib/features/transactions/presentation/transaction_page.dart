import 'package:drift/drift.dart' hide Column;
import 'package:financer/features/transactions/presentation/new_transaction_page.dart';
import 'package:financer/features/transactions/presentation/transaction_widget.dart';
import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../../../core/util/date_helper.dart';
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
    DateTime date = DateTime(1950);
    return Scaffold(
      body: InfiniteListView<Transaction>(
        pageSize: 20,
        loader: getTransactionsPaged,
        itemBuilder: (context, transaction) {
          final transactionWidget = TransactionWidget(transaction: transaction);
          if (!isSameDay(transaction.date, date)) {
            date = transaction.date;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "${date.day}.${date.month}.${date.year}.",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                transactionWidget
              ],
            );
          }
          return transactionWidget;
        },
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