import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

Iterable<Insertable<Currency>> defaultCurrencies = [
  CurrenciesCompanion.insert(code: 'RSD', name: 'Serbian Dinar'),
  CurrenciesCompanion.insert(code: 'EUR', name: 'Euro'),
];