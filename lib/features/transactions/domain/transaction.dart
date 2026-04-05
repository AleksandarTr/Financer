import 'package:drift/drift.dart';
import 'package:financer/features/accounts/domain/account.dart';

import 'category.dart';

enum TransactionType {
  income,
  expense,
  transfer
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