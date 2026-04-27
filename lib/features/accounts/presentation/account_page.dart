import 'package:drift/drift.dart' hide Column;
import 'package:financer/core/database/database_shorthand.dart';
import 'package:financer/features/accounts/presentation/new_account_page.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/infinite_list_view.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/account.dart';
import 'account_widget.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  SimpleSelectStatement getAccountsPaged() {
    return accounts.select()
      ..orderBy([(t) => OrderingTerm(expression: t.type)]);
  }

  Widget _buildAccountList() {
    AccountType? type;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: InfiniteListView<Account>(
        pageSize: 20,
        loader: getAccountsPaged,
        itemBuilder: (context, account) {
          final accountWidget = AccountWidget(account: account);
          if (type != account.type) {
            type = account.type;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    type!.getLabel(l10n),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                accountWidget
              ],
            );
          }
          return accountWidget;
        },
      ),
      floatingActionButton: _buildNewAccountButton(),
    );
  }

  Widget _buildNewAccountButton() {
    return FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NewAccountPage()),
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
        child: _buildAccountList()
    );
  }
}