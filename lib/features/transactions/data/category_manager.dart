import 'package:drift/drift.dart';
import 'package:financer/features/transactions/domain/category.dart';

import '../../../core/database/database.dart';
import '../../../core/database/table_manager.dart';

class CategoryManager extends TableManager<Category, int> {
  CategoryManager._internal();
  static final CategoryManager _instance = CategoryManager._internal();
  factory CategoryManager() => _instance;

  Map<int, Category>? _categoryMap;

  // We store the loading operation itself
  Future<void>? _loadingFuture;

  @override
  Future<Map<int, Category>> get map async {
    await _loadMap();
    return _categoryMap!;
  }

  @override
  Future<List<Category>> get values async {
    await _loadMap();
    return _categoryMap!.values.toList();
  }

  Future<void> _loadMap() async {
    // 1. If data is already here, do nothing
    if (_categoryMap != null) return;

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
      final categories = await AppDatabase.instance.categories.all().get();
      _categoryMap = {for (var a in categories) a.id: a};
    } finally {
      // Clear the future tracker so we can load again if cache is cleared
      _loadingFuture = null;
    }
  }

  @override
  Future<Category?> operator[] (int id) async {
    await _loadMap();
    return _categoryMap?[id];
  }

  @override
  void clearCache() {
    _categoryMap = null;
    _loadingFuture = null;
  }
}