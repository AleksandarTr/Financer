abstract interface class ExchangeSource {
  void fetchExchangeRates(DateTime date, String currency);
}