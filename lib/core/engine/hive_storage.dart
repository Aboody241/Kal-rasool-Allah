import 'package:hive/hive.dart';
import 'storage_interface.dart';

class HiveStorage implements Storage {
  final String boxName;
  late Box _box;

  HiveStorage(this.boxName);

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  @override
  Future<void> save(String key, dynamic value) async {
    await _box.put(key, value);
  }

  @override
  Future<dynamic> read(String key) async {
    return _box.get(key);
  }
}
