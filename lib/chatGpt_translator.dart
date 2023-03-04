import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class ChatGptTranslator {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String token = "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";

  Future<String> translate(String text) async {
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'model': 'gpt-3.5-turbo-0301',
      'messages': [
        {
          'role': 'user',
          'content': '將以下翻成繁體中文，保留原格式:\n$text'
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final translatedText = jsonResponse['choices'][0]['message']['content'].trim();
        return utf8.decode(translatedText.toString().codeUnits);
      } else {
        throw Exception('Failed to translate text.');
      }
    } on TimeoutException catch(e){
      debugPrint('TimeoutException: $e');
      throw Exception('Translate text timeout');
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception('Failed to translate text.');
    }
  }
}