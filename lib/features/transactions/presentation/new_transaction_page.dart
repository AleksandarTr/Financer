import 'package:drift/drift.dart' hide Column;
import 'package:financer/core/util/has_id.dart';
import 'package:financer/core/widgets/input_field.dart';
import 'package:financer/features/accounts/data/account_manager.dart';
import 'package:financer/features/transactions/data/category_manager.dart';
import 'package:financer/features/transactions/domain/category.dart';
import 'package:financer/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/database/database_shorthand.dart';
import '../../../core/widgets/dropdown_select.dart';
import '../../accounts/domain/account.dart';
import '../domain/transaction.dart';

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({super.key});

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final Transaction _transaction = Transaction();

  late final _nameController = FieldController<String>(
    onSave: (String value) => _transaction.name = value
  );

  late final _amountController = FieldController<double>(
    onSave: (double value) => _transaction.baseAmount = (value * 100).toInt()
  );

  late final _dateController = FieldController<DateTime>(
    onSave: (DateTime value) => _transaction.date = value,
    initialValue: DateTime.now()
  );

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _transaction.convertedAmount = _transaction.baseAmount;
      await transactions.insertOne(
        _transaction
      );
      if(mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          InputField(
            controller: _nameController,
            label: l10n.name,
            icon: Icons.receipt,
          ),
          const SizedBox(height: 10),
          InputField(
            controller: _amountController,
            label: l10n.amount,
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 10),
          InputField(
            controller: _dateController,
            label: l10n.date,
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 10),
          DropdownSelect<TransactionType, int>(
            icon: Icons.category,
              valueHolder: ValueProvider(
                  () async => TransactionType.values,
                  () async => TransactionType.values.asMap()),
              label: l10n.type,
              dropDownItem: (type) => DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    type.icon,
                    const SizedBox(width: 8),
                    Text(type.getLabel(l10n)),
                  ],
                ),
              ),
            onSaved: (value) => _transaction.type = TransactionType.values[value!]),
          if (_transaction.type == TransactionType.income || _transaction.type == TransactionType.transfer) ...[
            const SizedBox(height: 10),
            DropdownSelect<Account, int>(
              icon: Icons.account_balance,
              valueHolder: AccountManager(),
              label: l10n.fromAccount,
              dropDownItem: (account) => Text(account.name),
              onSaved: (account) async => _transaction.fromAccount = account,
            )
          ],
          if (_transaction.type == TransactionType.expense || _transaction.type == TransactionType.transfer) ...[
            const SizedBox(height: 10),
            DropdownSelect<Account, int>(
              icon: Icons.account_balance,
              valueHolder: AccountManager(),
              label: l10n.toAccount,
              dropDownItem: (account) => Text(account.name),
              onSaved: (id) async => _transaction.toAccount = id,
            )
          ],
          const SizedBox(height: 10),
          DropdownSelect<Category, int>(
            icon: Icons.label,
            valueHolder: CategoryManager(),
            label: l10n.category,
            dropDownItem: (category) => Text(category.name),
            onSaved: (id) async => _transaction.category = id!,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitData,
            child: Text(l10n.addTransaction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(
        top: BorderSide(
          color: _transaction.type.color,
          width: 3,
        )
      )),
        child: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildForm(),
        ),
      )
    )
    );
  }
}