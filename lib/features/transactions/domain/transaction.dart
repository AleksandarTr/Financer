import 'package:drift/drift.dart';
import 'package:financer/core/util/has_id.dart';
import 'package:financer/features/accounts/domain/account.dart';
import 'package:financer/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart' hide Table;

import 'category.dart';

enum TransactionType implements HasID<int> {
  income,
  expense,
  transfer;

  Color get color {
    switch (this) {
      case TransactionType.income: return Colors.green;
      case TransactionType.expense: return Colors.red;
      case TransactionType.transfer: return Colors.blue;
    }
  }

  Icon get icon {
    switch (this) {
      case TransactionType.income: return const Icon(Icons.arrow_upward, color: Colors.green);
      case TransactionType.expense: return const Icon(Icons.arrow_downward, color: Colors.red);
      case TransactionType.transfer: return const Icon(Icons.swap_horiz, color: Colors.blue);
    }
  }

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case TransactionType.income: return l10n.income;
      case TransactionType.expense: return l10n.expense;
      case TransactionType.transfer: return l10n.transfer;
    }
  }

  @override
  get id => index;
}

@UseRowClass(Transaction)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get baseAmount => integer()();
  IntColumn get convertedAmount => integer()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get type => intEnum<TransactionType>()();
  @ReferenceName('outgoingTransactions')
  IntColumn get fromAccount => integer().nullable().references(Accounts, #id)();
  @ReferenceName('incomingTransactions')
  IntColumn get toAccount => integer().nullable().references(Accounts, #id)();
  IntColumn get category => integer().references(Categories, #id)();
}

class Transaction implements Insertable<Transaction> {
  static final DateTime _defaultDate = DateTime(1970);

  int id;
  int baseAmount;
  int convertedAmount;
  String name;
  DateTime date;
  TransactionType type;
  int? fromAccount;
  int? toAccount;
  int category;

  Transaction({
    this.id = 0,
    this.baseAmount = 0,
    this.convertedAmount = 0,
    this.name = '',
    DateTime? date,
    this.type = TransactionType.expense,
    this.fromAccount,
    this.toAccount,
    this.category = 0,
  }) : date = date ?? _defaultDate;

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['base_amount'] = Variable<int>(baseAmount);
    map['converted_amount'] = Variable<int>(convertedAmount);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<int>(type.index);
    map['from_account'] = Variable<int>(fromAccount);
    map['to_account'] = Variable<int>(toAccount);
    map['category'] = Variable<int>(category);
    return map;
  }
}