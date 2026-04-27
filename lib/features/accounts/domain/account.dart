
import 'package:drift/drift.dart';
import 'package:financer/core/util/has_id.dart';
import 'package:flutter/material.dart' hide Table;

import '../../../generated/l10n/app_localizations.dart';
import '../../currencies/domain/currency.dart';

enum AccountType implements HasID<int> {
  cash,
  checkingAccount;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case cash: return l10n.cash;
      case checkingAccount: return l10n.checkingAccount;
    }
  }
  
  Icon get icon {
    switch(this) {
      case cash: return const Icon(Icons.wallet, color: Colors.orange);
      case checkingAccount: return const Icon(Icons.account_balance, color: Colors.blue);
    }
  }

  @override
  int get id => index;
}

@UseRowClass(Account)
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get startingBalance => integer()();
  IntColumn get currentBalance => integer()();
  IntColumn get type => intEnum<AccountType>()();
  TextColumn get currency => text().references(Currencies, #code)();
}

class Account implements HasID<int> {
  @override
  int id;
  String name;
  int startingBalance;
  int currentBalance;
  AccountType type;
  String currency;

  Account({
    this.id = 0,
    this.name = "",
    this.startingBalance = 0,
    this.currentBalance = 0,
    this.type = AccountType.cash,
    this.currency = "EUR",
  });
}