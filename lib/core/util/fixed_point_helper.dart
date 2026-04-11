const int priceFixedDecimalPlaces = 2;
const int priceMultiplier = 100; // 10^priceFixedDecimalPlaces

String priceToString(int price) {
  final full = price ~/ priceMultiplier;
  final cents = price % priceMultiplier;
  return '$full.${cents.toString().padLeft(2, '0')}';
}