import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  final String apiKey;
  final String endpoint;

  GroqService({
    String? apiKey,
    this.endpoint = 'https://api.groq.com/v1/chat/completions',
  }) : apiKey = apiKey ?? dotenv.env['GROQ_API_KEY'] ?? '';

  Future<String?> sendPrompt(String prompt) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama-2-70b-chat', // Cambia el modelo si es necesario
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 512,
        'temperature': 0.7,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'] as String?;
    } else {
      // Manejo de errores
      print('Groq API error: \\${response.statusCode} \\${response.body}');
      return null;
    }
  }
}
