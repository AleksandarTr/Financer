import 'package:drift/drift.dart';
import 'package:financer/core/database/database.dart';
import 'package:financer/core/database/table_manager.dart';

class CurrencyManager extends TableManager<Currency, String> {
  CurrencyManager._internal();
  static final CurrencyManager _instance = CurrencyManager._internal();
  factory CurrencyManager() => _instance;

  Map<String, Currency>? _currencyMap;

  // We store the loading operation itself
  Future<void>? _loadingFuture;

  @override
  Future<Map<String, Currency>> get map async {
    await _loadMap();
    return _currencyMap!;
  }

  @override
  Future<List<Currency>> get values async {
    await _loadMap();
    return _currencyMap!.values.toList();
  }

  Future<void> _loadMap() async {
    // 1. If data is already here, do nothing
    if (_currencyMap != null) return;

    // 2. If a load is already in progress, just wait for it
    if (_loadingFuture != null) {
      return _loadingFuture;
    }

    // 3. Otherwise, start the load and store the future
    _loadingFuture = _performLoad();
    return _loadingFuture;
  }

  Future<void> _performLoad() async {
    try {
      final currencies = await AppDatabase.instance.currencies.all().get();
      _currencyMap = {for (var a in currencies) a.code: a};
    } finally {
      // Clear the future tracker so we can load again if cache is cleared
      _loadingFuture = null;
    }
  }

  @override
  Future<Currency?> operator[] (String code) async {
    await _loadMap();
    return _currencyMap?[code];
  }

  @override
  void clearCache() {
    _currencyMap = null;
    _loadingFuture = null;
  }
}