import '../../../core/database/database.dart';

abstract interface class ExchangeSource {
  Future<List<ConversionRate>> fetchExchangeRates(DateTime date, String currency);
}