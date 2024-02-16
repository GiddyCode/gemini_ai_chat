library gemini_ai;

import 'dart:io';
import 'package:dio/dio.dart';
import '../config/gemini_ai_configuration.dart';
import '../models/gemini_ai_response.dart';
import '../safety_regulations/gemini_ai_safety_settings.dart';
import '../services/gemini_ai_service.dart';
import '../utils/gemini_ai_file_converter.dart';
import '../utils/gemini_ai_string_utils.dart';

class GeminiAI {
  String apiKey;
  GenerationConfig? config;
  List<SafetySettings>? safetySettings;
  String? model = Strings.geminiTextModel;
  late GeminiService _geminiService;

  GeminiAI({
    required this.apiKey,
    this.config,
    this.safetySettings,
    this.model,
  }) {
    _geminiService = GeminiService(Dio());
  }

  Future<GeminiAIResponse> generateTextFromQuery(String query) async {
    try {
      final httpResponse = await _geminiService.generateText(
        query: query,
        apiKey: apiKey,
        config: config,
        safetySettings: safetySettings,
        model: Strings.geminiTextModel,
      );

      final text = httpResponse.candidates
          .map((candidate) => candidate.content!['parts'])
          .expand((parts) => parts)
          .map((part) => part['text'])
          .join('');

      return GeminiAIResponse(text: text, response: httpResponse);
    } catch (error) {
      throw Exception('Failure generating text: $error');
    }
  }

  Future<GeminiAIResponse> generateTextFromQueryAndImages({
    required String query,
    required File image,
  }) async {
    var convertedImage = FileConverter.convertIntoBase64(image);
    try {
      final httpResponse = await _geminiService.generateTextAndImages(
        query: query,
        apiKey: apiKey, 
        image: convertedImage,
        config: config,
        safetySettings: safetySettings,
        model: Strings.geminiVisionModel,
      );

      final text = httpResponse.candidates
          .map((candidate) => candidate.content!['parts'])
          .expand((parts) => parts)
          .map((part) => part['text'])
          .join('');

      return GeminiAIResponse(text: text, response: httpResponse);
    } catch (error) {
      throw Exception('Error generating response: $error');
    }
  }
}
