/// Data storage for [D]
abstract class DataStorage<D> {
  /// Get data from storage.
  Future<D> loadData();

  /// Save [data] to storage
  Future<bool> saveData(D data);
}
