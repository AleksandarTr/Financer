import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class AccountManager {
  AccountManager._internal();
  static final AccountManager _instance = AccountManager._internal();
  factory AccountManager() => _instance;

  Map<int, Account>? _accountMap;

  // We store the loading operation itself
  Future<void>? _loadingFuture;

  Future<Map<int, Account>> get accountMap async {
    await _loadMap();
    return _accountMap!;
  }

  Future<List<Account>> get accounts async {
    await _loadMap();
    return _accountMap!.values.toList();
  }

  Future<void> _loadMap() async {
    // 1. If data is already here, do nothing
    if (_accountMap != null) return;

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
      final accounts = await AppDatabase.instance.accounts.all().get();
      _accountMap = {for (var a in accounts) a.id: a};
    } finally {
      // Clear the future tracker so we can load again if cache is cleared
      _loadingFuture = null;
    }
  }

  Future<Account?> operator[] (int id) async {
    await _loadMap();
    return _accountMap?[id];
  }

  void clearCache() {
    _accountMap = null;
    _loadingFuture = null;
  }
}