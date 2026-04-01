import 'package:petitparser/petitparser.dart';

enum _TokenType { date, amount, currency, vendor, other, card, possibleVendor, money }

class _Money {
  final String amount;
  final String currency;

  _Money(this.amount, this.currency);
}

class _ParsedToken {
  final int start;
  final int end;
  final dynamic value;
  final _TokenType type;

  _ParsedToken(this.start, this.end, this.value, this.type);
}

class TransactionMessageParser {
  final List<_ParsedToken> _allTokens = [];
  final Map<_TokenType, List<_ParsedToken>> _tokensByType = {};
  final String _message;
  late String _workingMessage;

  List<(_TokenType, Parser<String>)> _getParsers() {
    // TODO: Add more date formats
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

    // TODO: Add more currencies
    final currency = (string('RSD', ignoreCase: true) | string('EUR', ignoreCase: true)).flatten().trim();

    final card = (digit().plus() & char('*').plus() & digit().plus()).flatten().trim();

    final specialChars = char('&') | char('?');
    final uppercaseWord = (uppercase() | specialChars).plus() & word().not();
    final titlecaseWord = uppercase() & (lowercase() | specialChars).star();
    final vendorWord = (uppercaseWord | titlecaseWord).flatten();
    // TODO: Add more filler characters
    final separator = char(' ');
    final vendor = (vendorWord & (separator & (vendorWord | digit().plus())).plus()).flatten().trim();

    return [
      (_TokenType.card, card),
      (_TokenType.date, date),
      (_TokenType.amount, amount),
      (_TokenType.currency, currency),
      (_TokenType.vendor, vendor),
      (_TokenType.possibleVendor, vendorWord.flatten()),
    ];
  }

  static const String sentinel = '\x1F';

  void _extractTokens(Parser<String> parser, _TokenType type) {
    final matches = parser.token().allMatches(_workingMessage).toList();
    for (final m in matches) {
      _workingMessage = _workingMessage.replaceRange(m.start, m.stop, sentinel * (m.stop - m.start));
      final token = _ParsedToken(m.start, m.stop, m.value, type);
      _allTokens.add(token);
      _tokensByType[type]?.add(token);
    }
  }

  void _extractRemainder() {
    final parser = char(sentinel).neg().plus().flatten();
    final matches = parser.token().allMatches(_workingMessage).toList();
    for (final m in matches) {
      final token = _ParsedToken(m.start, m.stop, m.value, _TokenType.other);
      _allTokens.add(token);
      _tokensByType[_TokenType.other]?.add(token);
    }
  }

  TransactionMessageParser(this._message) {
    _workingMessage = _message;
    List<(_TokenType, Parser<String>)> parsers = _getParsers();

    for(final (type, parser) in parsers) {
      _extractTokens(parser, type);
    }
    _extractRemainder();
    _allTokens.sort((t1, t2) => t1.start.compareTo(t2.start));

    for (int i = 0; i < _allTokens.length; i++) {
      _ParsedToken token = _allTokens[i];
      if (token.type == _TokenType.amount
          && i + 1 < _allTokens.length && _allTokens[i + 1].type == _TokenType.currency) {
        _tokensByType[_TokenType.money]?.add(
            _ParsedToken(
                token.start,
                _allTokens[i + 1].end,
                _Money(token.value, _allTokens[i + 1].value),
                _TokenType.money)
        );
      }

      print("${token.value} - ${token.type}");
    }
  }
}