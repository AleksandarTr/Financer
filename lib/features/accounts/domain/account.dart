import 'package:drift/drift.dart';

import '../../currencies/domain/currency.dart';

enum AccountType {
  cash,
  checkingAccount
}

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get startingBalance => integer()();
  IntColumn get currentBalance => integer()();
  IntColumn get type => intEnum<AccountType>()();
  TextColumn get currency => text().references(Currencies, #code)();
}