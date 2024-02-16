import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_ai_chat/config/gemini_ai_configuration.dart';
import 'package:gemini_ai_chat/gemini_ai.dart';
import 'dart:io';

import 'package:gemini_ai_chat/models/gemini_ai_response.dart';
import 'package:gemini_ai_chat/safety_regulations/gemini_ai_safety_category.dart';
import 'package:gemini_ai_chat/safety_regulations/gemini_ai_safety_settings.dart';
import 'package:gemini_ai_chat/safety_regulations/gemini_ai_safety_threshold.dart';


void main() {
  group('GeminiAI', () {
    test('generateTextFromQuery should return GeminiAIResponse with text',
        () async {
      final geminiAi = createGeminiAIMock();
      final response = await geminiAi.generateTextFromQuery('test query');

      expect(response, isA<GeminiAIResponse>());
      expect(response.text, isNotEmpty);
    });

    test('generateTextFromQueryAndImages should return GeminiAIResponse with text',
        () async {
      final geminiAi = createGeminiAIMock();
      final file = File('path/to/image.jpg'); // Provide a valid image path
      final response = await geminiAi.generateTextFromQueryAndImages(
        query: 'test query',
        image: file,
      );

      expect(response, isA<GeminiAIResponse>());
      expect(response.text, isNotEmpty);
    });
  });
}

GeminiAI createGeminiAIMock() {
  return GeminiAI(
    apiKey: 'mockApiKey',
    config: GenerationConfig(
      temperature: 0.8,
      maxOutputTokens: 100,
      topP: 0.7,
      topK: 50,
      stopSequences: ['stop'],
    ),
    safetySettings: [
      SafetySettings(
        category: SafetyCategory.HARM_CATEGORY_HATE_SPEECH,
        threshold: SafetyThreshold.BLOCK_ONLY_HIGH,
      ),
    ],
    model: 'gemini-pro',
  );
}
