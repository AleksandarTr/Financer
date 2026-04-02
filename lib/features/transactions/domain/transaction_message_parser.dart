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
  final Map<_TokenType, List<_ParsedToken>> _tokensByType = {
    for (var type in _TokenType.values) type: []
  };
  final String _message;
  late String _workingMessage;
  final List<String> _sentenceStructure = [];

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
    final vendorWord = (uppercaseWord | titlecaseWord | digit().plus()).flatten();
    // TODO: Add more filler characters
    final separator = char(' ');
    final vendor = (vendorWord & (separator & vendorWord).plus()).flatten().trim();

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

  void _extractMoneyTokens() {
    for (int i = 0; i < _allTokens.length - 1; i++) {
      final current = _allTokens[i];
      final next = _allTokens[i + 1];

      final isAmountCurrency = current.type == _TokenType.amount && next.type == _TokenType.currency;
      final isCurrencyAmount = current.type == _TokenType.currency && next.type == _TokenType.amount;

      if (isAmountCurrency || isCurrencyAmount) {
        final amount = isAmountCurrency ? current.value : next.value;
        final currency = isAmountCurrency ? next.value : current.value;

        _tokensByType[_TokenType.money]?.add(_ParsedToken(
          current.start,
          next.end,
          _Money(amount, currency),
          _TokenType.money,
        ));
      }
    }
  }

  void _extractSentenceStructure() {
    bool hasVendor = _tokensByType[_TokenType.vendor]?.isNotEmpty ?? false;
    for (_ParsedToken token in _allTokens) {
      switch(token.type) {
        case _TokenType.other:
          _sentenceStructure.add(token.value);
          break;
        case _TokenType.possibleVendor:
          if(hasVendor) _sentenceStructure.add(token.value);
          break;
        default:
          break;
      }
    }
  }

  int _generateStableHash(List<String> structure) {
    final String raw = structure.join('|');

    int hash = 0xcbf29ce484222325;
    const int prime = 0x100000001b3;

    for (int i = 0; i < raw.length; i++) {
      hash ^= raw.codeUnitAt(i);
      hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF;
    }

    return hash;
  }

  TransactionMessageParser(this._message) {
    _workingMessage = _message;
    List<(_TokenType, Parser<String>)> parsers = _getParsers();

    for(final (type, parser) in parsers) {
      _extractTokens(parser, type);
    }
    _extractRemainder();
    _allTokens.sort((t1, t2) => t1.start.compareTo(t2.start));

    _extractMoneyTokens();
    _extractSentenceStructure();
  }
}