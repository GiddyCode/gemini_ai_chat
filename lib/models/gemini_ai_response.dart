import 'gemini_ai_http_response.dart';

class GeminiAIResponse {
  String text;
  GeminiAIHttpResponse response;

  GeminiAIResponse({
    required this.text,
    required this.response,
  });
}
