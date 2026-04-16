import '../util/has_id.dart';

abstract class TableManager<T, K> extends ValueHolder<T, K> {
  Future<T?> operator[] (K id);
  void clearCache();
}