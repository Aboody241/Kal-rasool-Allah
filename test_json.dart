import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/content/azkar.json');
  final jsonString = file.readAsStringSync();
  final List<dynamic> jsonList = jsonDecode(jsonString);
  
  final Map<String, List<int>> textToIds = {};
  bool hasError = false;

  for (int i = 0; i < jsonList.length; i++) {
    final json = jsonList[i];
    try {
      final id = json['id'] as int;
      final text = json['text'] as String;
      
      // Clean text to avoid small whitespace differences
      final cleanText = text.trim().replaceAll(RegExp(r'\s+'), ' ');
      
      if (textToIds.containsKey(cleanText)) {
        textToIds[cleanText]!.add(id);
      } else {
        textToIds[cleanText] = [id];
      }
    } catch (e) {
      print('Error at index $i (id: ${json["id"]}): $e');
      hasError = true;
    }
  }

  if (hasError) {
    return;
  }

  print('Total items checked: ${jsonList.length}');
  
  bool duplicatesFound = false;
  textToIds.forEach((text, ids) {
    if (ids.length > 1) {
      duplicatesFound = true;
      print('Duplicate text: "$text" found in IDs: $ids');
    }
  });

  if (!duplicatesFound) {
    print('No duplicates found!');
  }
}
