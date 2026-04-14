import 'package:drift/drift.dart';
import 'package:financer/core/database/database.dart';
import 'package:financer/core/database/database_shorthand.dart';

class AccountHelper {
  static Future<Currency> getCurrency(Account account) async {
    return (AppDatabase.instance.currencies.select()
        ..where((currency) => currency.code.equals(account.currency))).getSingle();
  }

  static Future<Currency> getCurrencyFromId(int id) async {
    final query = AppDatabase.instance.currencies.select().join([
      innerJoin(
        AppDatabase.instance.accounts,
        AppDatabase.instance.accounts.currency.equalsExp(
            AppDatabase.instance.currencies.code
        ),
      ),
    ])
      ..where(AppDatabase.instance.accounts.id.equals(id));

    final row = await query.getSingle();
    return row.readTable(AppDatabase.instance.currencies);
  }

  static Future<Account> getAccountFromId(int id) async {
    return (accounts.select()
      ..where((account) => account.id.equals(id))).getSingle();
  }
}