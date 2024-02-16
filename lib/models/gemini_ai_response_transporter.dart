class GeminiAIResponseTransporter {
  String? finishReason;
  int index;
  Map<String, dynamic>? content = {"parts": [], "role": "model"};
  List safetyRatings;

  GeminiAIResponseTransporter({
    this.finishReason,
    required this.index,
    this.content,
    required this.safetyRatings,
  });

  factory GeminiAIResponseTransporter.fromJson(Map<String, dynamic> json) {
    return GeminiAIResponseTransporter(
      finishReason: json['finishReason'],
      index: json['index'],
      content: json['content'],
      safetyRatings: json['safetyRatings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'finishReason': finishReason,
      'index': index,
      'content': content,
      'safetyRatings': safetyRatings,
    };
  }
}
