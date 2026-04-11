import 'package:drift/drift.dart' hide Column;
import 'package:financer/features/accounts/data/account_manager.dart';
import 'package:financer/features/transactions/data/category_manager.dart';
import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../domain/transaction.dart';

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({super.key});

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final _dateController = TextEditingController();

  TransactionType? _selectedType = TransactionType.expense;
  Account? _selectedFromAccount;
  Account? _selectedToAccount;
  Category? _selectedCategory;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: DateTime.now().add(Duration(days: 365 * 100)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _selectedDate.toString().split(' ')[0];
      });
    }
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final amount = (double.parse(_amountController.text) * 100).toInt();
      await AppDatabase.instance.transactions.insertOne(
        TransactionsCompanion(
          name: Value(_nameController.text),
          baseAmount: Value(amount),
          date: Value(_selectedDate),
          type: Value(_selectedType!),
          fromAccount: Value(_selectedFromAccount?.id),
          toAccount: Value(_selectedToAccount?.id),
          category: Value(_selectedCategory!.id),
          convertedAmount: Value(amount)
        )
      );
      if(mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  List<DropdownMenuItem<TransactionType>> _buildTypeDropdownItems() {
    return [
      DropdownMenuItem(
        value: TransactionType.income,
        child: Row(
          children: const [
            Icon(Icons.arrow_upward, color: Colors.green),
            SizedBox(width: 8),
            Text('Income'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: TransactionType.expense,
        child: Row(
          children: const [
            Icon(Icons.arrow_downward, color: Colors.red),
            SizedBox(width: 8),
            Text('Expense'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: TransactionType.transfer,
        child: Row(
          children: const [
            Icon(Icons.swap_horiz, color: Colors.blue),
            SizedBox(width: 8),
            Text('Transfer'),
          ],
        ),
      ),
    ];
  }

  Widget _buildAccountDropdown(String label, Function (Future<Account?>) onSelected) {
    return FutureBuilder<List<Account>>(
      future: AccountManager().accounts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.account_balance_wallet),
          ),
          items: snapshot.data!.map((account) {
            return DropdownMenuItem<int>(
              value: account.id,
              child: Text(account.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              onSelected(AccountManager()[value!]);
            });
          },
          validator: (value) => value == null ? 'Please select an account' : null,
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<Category>>(
      future: CategoryManager().categories,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return TextFormField(
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Category',
              suffixIcon: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final categories = snapshot.data!;

        return DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.label),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<int>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = categories.firstWhere((cat) => cat.id == value);
            });
          },
        );
      },
    );
  }

  Widget _buildForm() {
    _dateController.text = _selectedDate.toString().split(' ')[0];

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Transaction Name'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a name';
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _selectDate(context),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please select a date';
              return null;
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<TransactionType>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Type',
              prefixIcon: Icon(Icons.category),
            ),
            items: _buildTypeDropdownItems(),
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
            validator: (value) => value == null ? 'Please select a type' : null,
            onSaved: (value) => _selectedType = value,
          ),
          if (_selectedType == TransactionType.income || _selectedType == TransactionType.transfer) ...[
            const SizedBox(height: 10),
            _buildAccountDropdown("From account", (account) async => _selectedFromAccount = (await account)!)
          ],
          if (_selectedType == TransactionType.expense || _selectedType == TransactionType.transfer) ...[
            const SizedBox(height: 10),
            _buildAccountDropdown("To account", (account) async => _selectedToAccount = (await account)!)
          ],
          const SizedBox(height: 10),
          _buildCategoryDropdown(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitData,
            child: const Text('Add Transaction'),
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
          color: _selectedType?.color ?? Colors.grey,
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