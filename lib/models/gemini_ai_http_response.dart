import '../models/gemini_ai_response_transporter.dart';

class GeminiAIHttpResponse {
  List<GeminiAIResponseTransporter> candidates;
  Map<String, dynamic>? promptFeedback = {"safetyRatings": []};

  GeminiAIHttpResponse({
    required this.candidates,
    this.promptFeedback,
  });

  factory GeminiAIHttpResponse.fromJson(Map<String, dynamic> json) {
    List<GeminiAIResponseTransporter> responseCandidates = [];
    for (var candidate in json['candidates']) {
      responseCandidates.add(
        GeminiAIResponseTransporter.fromJson(candidate),
      );
    }
    return GeminiAIHttpResponse(
      candidates: responseCandidates,
      promptFeedback: json['promptFeedback'],
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> localCandidates = [];
    for (var candidate in candidates) {
      localCandidates.add(candidate.toJson());
    }
    return {'candidates': candidates, 'promptFeedback': promptFeedback};
  }
}
