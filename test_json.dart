import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/content/dua.json');
  final jsonString = file.readAsStringSync();
  final List<dynamic> jsonList = jsonDecode(jsonString);
  
  for (int i = 0; i < jsonList.length; i++) {
    final json = jsonList[i];
    try {
      final id = json['id'] as int;
      final text = json['text'] as String;
      final category = json['category'] as String;
      final source = json['source'] as String?;
    } catch (e) {
      print('Error at index $i (id: ${json["id"]}): $e');
      print('Data: $json');
      return;
    }
  }
  print('All items parsed successfully!');
}
