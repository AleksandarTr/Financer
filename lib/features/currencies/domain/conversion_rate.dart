import 'package:drift/drift.dart';
import 'package:financer/features/currencies/domain/currency.dart';

class DateOnlyConverter extends TypeConverter<DateTime, DateTime> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(DateTime fromDb) => fromDb; // Already normalized in DB

  @override
  DateTime toSql(DateTime value) {
    // Strip time: 2026-04-14 10:45:00 -> 2026-04-14 00:00:00
    return DateTime.utc(value.year, value.month, value.day);
  }
}

class ConversionRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  @ReferenceName('ratesAsBase')
  TextColumn get fromCurrency => text().references(Currencies, #code)();
  @ReferenceName('ratesAsTarget')
  TextColumn get toCurrency => text().references(Currencies, #code)();
  IntColumn get rate => integer()();
  DateTimeColumn get date => dateTime().map(const DateOnlyConverter())();
}