class FixedPointHelper {
  static const int priceFixedDecimalPlaces = 2;
  static const int priceMultiplier = 100; // 10^priceFixedDecimalPlaces

  static const int conversionRateFixedDecimalPlaces = 4;
  static const int conversionRateMultiplier = 10000; // 10^conversionRateFixedDecimalPlaces


  static String priceToString(int price) {
    final full = price ~/ priceMultiplier;
    final cents = price % priceMultiplier;
    return '$full.${cents.toString().padLeft(2, '0')}';
  }

  static String conversionRateToString(int rate) {
    final full = rate ~/ conversionRateMultiplier;
    final decimals = rate % conversionRateMultiplier;
    return '$full.${decimals.toString().padLeft(6, '0')}';
  }

  static int convertPrice(int price, int rate) {
    BigInt p = BigInt.from(price);
    BigInt r = BigInt.from(rate);
    BigInt scale = BigInt.from(conversionRateMultiplier);
    return (p * r ~/ scale).toInt();
  }
}