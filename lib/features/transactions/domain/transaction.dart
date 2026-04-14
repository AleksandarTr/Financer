import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:financer/features/accounts/domain/account.dart';
import 'package:flutter/material.dart' hide Table;

import 'category.dart';

enum TransactionType {
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
}

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