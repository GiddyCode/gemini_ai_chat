class GenerationConfig {
  double temperature;
  int maxOutputTokens;
  double topP;
  int topK;
  List<String>? stopSequences;

  GenerationConfig({
    required this.temperature,
    required this.maxOutputTokens,
    required this.topP,
    required this.topK,
    this.stopSequences,
  });

  factory GenerationConfig.fromJson(Map<String, dynamic> json) {
    return GenerationConfig(
      temperature: json['temperature'],
      maxOutputTokens: json['maxOutputTokens'],
      topP: json['topP'],
      topK: json['topK'],
      stopSequences: json['stopSequences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'maxOutputTokens': maxOutputTokens,
      'topP': topP,
      'topK': topK,
      'stopSequences': stopSequences,
    };
  }
}
