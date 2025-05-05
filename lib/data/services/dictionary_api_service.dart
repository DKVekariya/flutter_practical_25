import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';

class DictionaryApiService {
  final String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  final SharedPreferences _prefs;

  DictionaryApiService(this._prefs);

  Future<Word?> fetchWord(String word) async {
    // Check cache
    final cached = _prefs.getString('word_$word');
    if (cached != null) {
      return Word.fromJson(jsonDecode(cached));
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/$word'));
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final wordData = Word.fromJson(json[0]);
        // Cache result
        await _prefs.setString('word_$word', jsonEncode(json[0]));
        return wordData;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<List<String>> loadDictionary() async {
    final String jsonString = await rootBundle.loadString('assets/dictionary.json');
    return List<String>.from(jsonDecode(jsonString));
  }
}