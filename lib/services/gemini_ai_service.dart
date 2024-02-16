import 'package:dio/dio.dart';
import 'package:gemini_ai_chat/safety_regulations/gemini_ai_safety_settings.dart';
import '../config/gemini_ai_configuration.dart';
import '../constants/gemini_ai_constants.dart';
import '../models/gemini_ai_http_response.dart';

class GeminiService {
  final Dio _dio;

  GeminiService(this._dio);

  Future<GeminiAIHttpResponse> generateText({
    required String query,
    required String apiKey,
    required GenerationConfig? config,
    required List<SafetySettings>? safetySettings,
    String model = 'gemini-pro',
  }) async {
    try {
      final response = await _dio.post(
        '${Constants.geminiAIEndpoint}/$model:generateContent',
        queryParameters: {'key': apiKey},
        data: {
          "contents": [
            {
              "parts": [
                {"text": query}
              ]
            }
          ],
          "safetySettings": _convertSafetySettings(safetySettings ?? []),
          "generationConfig": config?.toJson(),
        },
      );

      return GeminiAIHttpResponse.fromJson(response.data);
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<GeminiAIHttpResponse> generateTextAndImages({
    required String query,
    required String apiKey,
    required dynamic image,
    required GenerationConfig? config,
    required List<SafetySettings>? safetySettings,
    String model = 'gemini-pro-vision',
  }) async {
    try {
      final response = await _dio.post(
        '${Constants.geminiAIEndpoint}/$model:generateContent',
        queryParameters: {'key': apiKey},
        data: {
          "contents": [
            {
              "parts": [
                {"text": query},
                {
                  "inline_data": {"mime_type": "image/jpeg", "data": image}
                },
              ],
            }
          ],
          "safetySettings": _convertSafetySettings(safetySettings ?? []),
          "generationConfig": config?.toJson(),
        },
      );

      return GeminiAIHttpResponse.fromJson(response.data);
    } catch (error, s) {
      print("this is throwing an error in $s");
      throw _handleError(error);
    }
  }

  List<Map<String, dynamic>> _convertSafetySettings(
    List<SafetySettings> safetySettings,
  ) {
    return safetySettings
        .map((safetySetting) => safetySetting.toJson())
        .toList();
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        return Exception(
          'Text Generation Failed. \nStatus code:${response.statusCode}\nResponse:${response.data}',
        );
      }
    }
    return Exception('Error Occurred during Text Generation: $error');
  }
}
