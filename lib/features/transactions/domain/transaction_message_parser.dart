import 'package:petitparser/petitparser.dart';

enum _TokenType { date, amount, currency, vendor, other }

class _Money {
  final String amount;
  final String currency;

  _Money(this.amount, this.currency);
}

class TransactionMessageParser {
  final List<String> _amounts = [];
  final List<String> _dates = [];
  final List<String> _currencies = [];
  final List<String> _vendors = [];
  final List<String> _others = [];
  final List<_Money> _money = [];

  ChoiceParser<dynamic> _getParser() {
    final date = (digit().times(2) & char('.') & digit().times(2) & char('.') & digit().times(4))
        .flatten()
        .trim();

    final thousandsAm = char(',') & digit().times(3);
    final decimalsAm = char('.') & digit().times(2) & digit().not();

    final thousandsEu = char('.') & digit().times(3);
    final decimalsEu = char(',') & digit().times(2) & digit().not();

    final euTail = (thousandsEu.star() & decimalsEu);
    final amTail = (thousandsAm.star() & decimalsAm);

    final amount = (
        digit().plus() &
        (euTail | amTail)
    ).flatten().trim();

    final currency = (string('RSD', ignoreCase: true) | string('EUR', ignoreCase: true)).flatten().trim();

    final delimiter = char('.') | char(',') | char(':') | char('/') | amount | currency | date;

    final uppercaseWord = uppercase().plus() & word().not();
    final titlecaseWord = uppercase() & lowercase().star();
    final vendorWord = (uppercaseWord | titlecaseWord).flatten();
    final filler = (digit() | char(' ') | char('&') | char('?')).flatten();
    final vendor = (vendorWord & (vendorWord | filler).star()).flatten().trim();

    final other = (vendor.not() & amount.not() & any()).starLazy(delimiter).flatten();

    return
      date.map((val) => (val, _TokenType.date)) |
      amount.map((val) => (val, _TokenType.amount)) |
      currency.map((val) => (val, _TokenType.currency)) |
      vendor.map((val) => (val, _TokenType.vendor)) |
      other.map((val) => (val, _TokenType.other));
  }

  TransactionMessageParser(String message) {
    final parser = _getParser();

    final destinations = {
      _TokenType.date: _dates,
      _TokenType.amount: _amounts,
      _TokenType.currency: _currencies,
      _TokenType.vendor: _vendors,
      _TokenType.other: _others,
    };

    List<(String, _TokenType)> tokens = parser.allMatches(message)
        .where((t) => t.$1.toString().isNotEmpty)
        .cast<(String, _TokenType)>()
        .toList();

    for (int i = 0; i < tokens.length; i++) {
      final value = tokens[i].$1;
      final type = tokens[i].$2;
      destinations[type]?.add(value);
      if (type == _TokenType.amount
          && i + 1 < tokens.length && tokens[i + 1].$2 == _TokenType.currency) {
        _money.add(_Money(value, tokens[i + 1].$1));
      }
    }
  }
}