import 'dart:convert';

enum CleaningStepType {
  redirect,
  removeQuery,
  stripFragment,
}

class CleaningStep {
  final CleaningStepType type;
  final Map<String, dynamic> params;

  CleaningStep({required this.type, Map<String, dynamic>? params})
      : params = params ?? const {};

  factory CleaningStep.fromJson(Map<String, dynamic> json) {
    return CleaningStep(
      type: CleaningStepType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] as String),
        orElse: () => CleaningStepType.removeQuery,
      ),
      params: (json['params'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.toString().split('.').last,
        'params': params,
      };
}

class CleaningStrategy {
  final String id;
  String name;
  List<CleaningStep> steps;
  bool isActive;

  CleaningStrategy({
    required this.id,
    required this.name,
    required this.steps,
    this.isActive = false,
  });

  factory CleaningStrategy.fromJson(Map<String, dynamic> json) {
    return CleaningStrategy(
      id: json['id'],
      name: json['name'],
      steps: (json['steps'] as List)
          .map((e) => CleaningStep.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'steps': steps.map((e) => e.toJson()).toList(),
        'isActive': isActive,
      };

  static String encodeList(List<CleaningStrategy> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<CleaningStrategy> decodeList(String data) {
    final decoded = jsonDecode(data) as List;
    return decoded
        .map((e) => CleaningStrategy.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
