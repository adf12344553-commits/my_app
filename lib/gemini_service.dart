// lib/ai_service.dart (or a new service file)
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Replace with your Groq or OpenRouter API key
  static const String groqApiKey = '';
  // Use the Groq or OpenRouter endpoint
  static const String apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  // Example model for Groq: 'llama3-70b-8192' or for OpenRouter: 'meta-llama/llama-3.3-70b-instruct:free'

  static Future<String> ask(String prompt) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama3-70b-8192', // Change this to your chosen model
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return 'Error: ${response.statusCode} - ${response.body}';
    }
  }
}
