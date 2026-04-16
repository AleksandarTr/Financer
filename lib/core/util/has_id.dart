abstract class HasID<T> {
  T get id;
}

abstract class ValueHolder<T, K> {
  Future<List<T>> get values;
  Future<Map<K, T>> get map;
}

class ValueProvider<T, K> implements ValueHolder<T, K> {
  final Future<List<T>> Function() _valuesProvider;
  final Future<Map<K, T>> Function() _mapProvider;

  ValueProvider(this._valuesProvider, this._mapProvider);

  @override
  Future<List<T>> get values => _valuesProvider();

  @override
  Future<Map<K, T>> get map => _mapProvider();
}