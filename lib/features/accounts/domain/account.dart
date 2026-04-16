import 'package:drift/drift.dart';
import 'package:financer/core/util/has_id.dart';

import '../../currencies/domain/currency.dart';

enum AccountType {
  cash,
  checkingAccount
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
  final int id;
  final String name;
  final int startingBalance;
  final int currentBalance;
  final AccountType type;
  final String currency;

  Account({
    required this.id,
    required this.name,
    required this.startingBalance,
    required this.currentBalance,
    required this.type,
    required this.currency,
  });
}