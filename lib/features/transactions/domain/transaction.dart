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
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get baseAmount => integer()();
  IntColumn get convertedAmount => integer()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get type => intEnum<TransactionType>()();
  IntColumn get fromAccount => integer().nullable().references(Accounts, #id)();
  IntColumn get toAccount => integer().nullable().references(Accounts, #id)();
  IntColumn get category => integer().references(Categories, #id)();
}