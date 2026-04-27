import 'package:financer/core/database/database.dart';
import 'package:financer/core/util/has_id.dart';
import 'package:financer/core/widgets/input_field.dart';
import 'package:financer/features/currencies/data/currency_manager.dart';
import 'package:financer/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/dropdown_select.dart';
import '../../accounts/domain/account.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({super.key});

  @override
  State<NewAccountPage> createState() => _NewAccountPageState();
}

class _NewAccountPageState extends State<NewAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final Account _account = Account();

  late final _nameController = FieldController<String>(
      onSave: (String value) => _account.name = value
  );

  late final _balanceController = FieldController<double>(
      onSave: (double value) => _account.startingBalance = (value * 100).toInt()
  );

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _account.currentBalance = _account.currentBalance;
      // await transactions.insertOne(
      //     _account
      // );
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
            icon: Icons.description,
          ),
          const SizedBox(height: 10),
          InputField(
            controller: _balanceController,
            label: l10n.startingBalance,
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 10),
          DropdownSelect<AccountType, int>(
            icon: Icons.category,
            valueHolder: ValueProvider(
                    () async => AccountType.values,
                    () async => AccountType.values.asMap()),
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
            onSaved: (value) => _account.type = AccountType.values[value!]
          ),
          const SizedBox(height: 10),
          DropdownSelect<Currency, String>(
            icon: Icons.money,
            valueHolder: CurrencyManager(),
            label: l10n.currency,
            dropDownItem: (currency) => Text(currency.name),
            onSaved: (code) async => _account.currency = code!,
            searchLabel: (currency) => currency.name
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitData,
            child: Text(l10n.addAccount),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildForm(),
        ),
      )
    );
  }
}