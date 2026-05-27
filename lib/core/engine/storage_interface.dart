abstract class Storage {
  /// Saves data to the persistent storage.
  Future<void> save(String key, dynamic value);

  /// Retrieves data from the persistent storage.
  Future<dynamic> read(String key);
}
