import 'database.dart';

final db = AppDatabase.instance;

$TransactionsTable get transactions => db.transactions;
$CategoriesTable get categories => db.categories;
$AccountsTable get accounts => db.accounts;
$CurrenciesTable get currencies => db.currencies;
$ConversionRatesTable get conversionRates => db.conversionRates;