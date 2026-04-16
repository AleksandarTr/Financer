import 'package:drift/drift.dart';
import 'package:financer/core/util/fixed_point_helper.dart';
import 'package:financer/features/accounts/domain/account_helper.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_shorthand.dart';
import '../../../core/util/date_helper.dart';
import '../../accounts/domain/account.dart';
import '../../transactions/domain/transaction.dart';

abstract class ExchangeEntity {
  Future<String> getCurrency();
}

class AccountEntity extends ExchangeEntity {
  final Account account;
  AccountEntity(this.account);

  @override
  Future<String> getCurrency() async {
    return account.currency;
  }
}

class CurrencyEntity extends ExchangeEntity {
  final Currency currency;
  CurrencyEntity(this.currency);

  @override
  Future<String> getCurrency() async {
    return currency.code;
  }
}

class IdEntity extends ExchangeEntity {
  final int id;
  IdEntity(this.id);

  @override
  Future<String> getCurrency() async {
    return (await AccountHelper.getAccountFromId(id)).currency;
  }
}

class Convertor {
  static Future<int> _getExchangeRate(String from, String to, Transaction? transaction) async {
    //TODO: Add pattern matching with the transaction, to get the previously used exchange rate
    final query = (conversionRates.select()
      ..where((rate) =>
      rate.fromCurrency.equals(from) & rate.toCurrency.equals(to) &
      rate.date.equals(normalize(transaction?.date ?? DateTime.now())))
      ..limit(1)).getSingle();

    final rate = await query;
    return rate.rate;
  }

  static Future<int> convert(
      int price, {
      int exchangeRate = -1,
      ExchangeEntity? from,
      ExchangeEntity? to,
      Transaction? transaction}) async {
    assert(from != null && to != null || exchangeRate > 0,
    'Must provide either accounts or currencies or a positive exchange rate');

    int rate;
    if (exchangeRate > 0) {
      rate = exchangeRate;
    } else {
      String fromCur = await from!.getCurrency();
      String toCur = await to!.getCurrency();

      if (fromCur == toCur) {
        rate = FixedPointHelper.conversionRateMultiplier;
      } else {
        rate = await _getExchangeRate(fromCur, toCur, transaction);
      }
    }

    return FixedPointHelper.convertPrice(price, rate);
  }
}