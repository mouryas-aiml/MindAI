class EmotionModel {
  final String id;
  final String userId;
  final String emotion;
  final double intensity;
  final String? trigger;
  final String? note;
  final DateTime timestamp;

  EmotionModel({
    required this.id,
    required this.userId,
    required this.emotion,
    required this.intensity,
    this.trigger,
    this.note,
    required this.timestamp,
  });

  factory EmotionModel.fromMap(Map<String, dynamic> data) {
    return EmotionModel(
      id: data['id'] as String,
      userId: data['userId'] as String,
      emotion: data['emotion'] as String,
      intensity: (data['intensity'] as num).toDouble(),
      trigger: data['trigger'] as String?,
      note: data['note'] as String?,
      timestamp: DateTime.parse(data['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'emotion': emotion,
      'intensity': intensity,
      'trigger': trigger,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  EmotionModel copyWith({
    String? id,
    String? userId,
    String? emotion,
    double? intensity,
    String? trigger,
    String? note,
    DateTime? timestamp,
  }) {
    return EmotionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emotion: emotion ?? this.emotion,
      intensity: intensity ?? this.intensity,
      trigger: trigger ?? this.trigger,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }
} 