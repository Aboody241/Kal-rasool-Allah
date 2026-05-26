import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllahName {
  final int id;
  final String name;
  final String meaning;
  final String description;

  AllahName({
    required this.id,
    required this.name,
    required this.meaning,
    required this.description,
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    return AllahName(
      id: json['id'] as int,
      name: json['name'] as String,
      meaning: json['meaning'] as String,
      description: json['description'] as String,
    );
  }
}

final namesOfAllahProvider = FutureProvider<List<AllahName>>((ref) async {
  final String response = await rootBundle.loadString('assets/content/allah_names.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => AllahName.fromJson(json)).toList();
});
