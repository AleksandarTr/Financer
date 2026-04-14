import 'dart:convert';
import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:financer/core/database/database.dart';
import 'package:financer/core/util/fixed_point_helper.dart';
import 'package:financer/features/currencies/data/exchange_source.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class _ExchangeRate {
  final DateTime date;
  final String base;
  final String quote;
  final double rate;

  _ExchangeRate({
    required this.date,
    required this.base,
    required this.quote,
    required this.rate,
  });

  factory _ExchangeRate.fromRawJson(String str) => _ExchangeRate.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory _ExchangeRate.fromJson(Map<String, dynamic> json) => _ExchangeRate(
    date: DateTime.parse(json["date"]),
    base: json["base"],
    quote: json["quote"],
    rate: json["rate"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "base": base,
    "quote": quote,
    "rate": rate,
  };
}

class FrankfurterApi implements ExchangeSource {
  @override
  Future<List<ConversionRate>> fetchExchangeRates(DateTime date, String currency) async {
    final String formattedDate = date.toIso8601String().split('T')[0];

    final url = Uri.https('api.frankfurter.dev', '/v2/rates', {
      'date': formattedDate,
      'base': currency
    });

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body) as List<Map<String, dynamic>>;
      return data.map((rate) => _ExchangeRate.fromJson(rate)).map((exchangeRate) => ConversionRate(
        id: 0,
        date: exchangeRate.date,
        fromCurrency: exchangeRate.base,
        toCurrency: exchangeRate.quote,
        rate: (exchangeRate.rate * FixedPointHelper.conversionRateMultiplier).toInt()
      )).toList();
    } catch (e) {
      return [];
    }
  }
}