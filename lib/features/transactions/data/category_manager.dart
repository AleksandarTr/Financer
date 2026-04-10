import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class CategoryManager {
  // 1. Private constructor
  CategoryManager._internal();

  // 2. The single instance
  static final CategoryManager _instance = CategoryManager._internal();

  // 3. Factory constructor returns the same instance every time
  factory CategoryManager() => _instance;

  // 4. The Cache
  List<Category>? _cachedCategories;

  // 5. The Lazy Loader
  Future<List<Category>> get categories async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    _cachedCategories = await AppDatabase.instance.categories.all().get();
    return _cachedCategories!;
  }

  // 6. Manual Refresh (Important!)
  void clearCache() {
    _cachedCategories = null;
  }}