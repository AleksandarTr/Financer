import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class AccountManager {
  // 1. Private constructor
  AccountManager._internal();

  // 2. The single instance
  static final AccountManager _instance = AccountManager._internal();

  // 3. Factory constructor returns the same instance every time
  factory AccountManager() => _instance;

  // 4. The Cache
  List<Account>? _cachedAccounts;

  // 5. The Lazy Loader
  Future<List<Account>> get accounts async {
    if (_cachedAccounts != null) {
      return _cachedAccounts!;
    }

    _cachedAccounts = await AppDatabase.instance.accounts.all().get();
    return _cachedAccounts!;
  }

  // 6. Manual Refresh (Important!)
  void clearCache() {
    _cachedAccounts = null;
  }}