import 'package:uuid/uuid.dart';

class HistoryItem {
  HistoryItem({
    String? id,
    required this.originalUrl,
    required this.cleanedUrl,
    required this.domain,
    required this.strategyId,
    required this.confidence,
    required this.createdAt,
    this.isFavorite = false,
    this.title,
    this.thumbnailUrl,
  }) : id = id ?? const Uuid().v4();

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      originalUrl: json['originalUrl'],
      cleanedUrl: json['cleanedUrl'],
      domain: json['domain'],
      strategyId: json['strategyId'],
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: (json['isFavorite'] is int)
          ? (json['isFavorite'] as int) == 1
          : (json['isFavorite'] == true),
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  final String id;
  final String originalUrl;
  final String cleanedUrl;
  final String domain;
  final String strategyId;
  final double confidence;
  final DateTime createdAt;
  final bool isFavorite;
  final String? title;
  final String? thumbnailUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalUrl': originalUrl,
      'cleanedUrl': cleanedUrl,
      'domain': domain,
      'strategyId': strategyId,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      // sqflite prefers int for booleans
      'isFavorite': isFavorite ? 1 : 0,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  HistoryItem copyWith({
    String? id,
    String? originalUrl,
    String? cleanedUrl,
    String? domain,
    String? strategyId,
    double? confidence,
    DateTime? createdAt,
    bool? isFavorite,
    String? title,
    String? thumbnailUrl,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      originalUrl: originalUrl ?? this.originalUrl,
      cleanedUrl: cleanedUrl ?? this.cleanedUrl,
      domain: domain ?? this.domain,
      strategyId: strategyId ?? this.strategyId,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
