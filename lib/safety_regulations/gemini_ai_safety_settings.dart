import 'gemini_ai_safety_category.dart';
import 'gemini_ai_safety_threshold.dart';

class SafetySettings {
  SafetyCategory category;
  SafetyThreshold threshold;

  SafetySettings({
    required this.category,
    required this.threshold,
  });

  factory SafetySettings.fromJson(Map<String, dynamic> json) {
    return SafetySettings(
      category: SafetyCategory.values
          .firstWhere((e) => e.toString() == '${json['category']}'),
      threshold: SafetyThreshold.values
          .firstWhere((e) => e.toString() == '${json['threshold']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'category': category.name, 'threshold': threshold.name};
  }
}
