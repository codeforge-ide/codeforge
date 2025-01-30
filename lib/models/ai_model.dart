class AIModel {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  const AIModel({
    required this.name,
    this.description = '',
    this.parameters = const {},
  });

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'parameters': parameters,
      };
}
