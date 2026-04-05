import 'package:drift/drift.dart';
import 'package:financer/features/currencies/domain/currency.dart';

class ConversionRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fromCurrencyId => integer().references(Currencies, #id)();
  IntColumn get toCurrencyId => integer().references(Currencies, #id)();
  IntColumn get rate => integer()();
  DateTimeColumn get date => dateTime()();
}