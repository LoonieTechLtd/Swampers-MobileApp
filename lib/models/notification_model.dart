import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String title;
  final String body;
  final DateTime createdAt;
  final String type;
  final String userId;
  final DateTime updatedAt;
  final bool read;
  final String notificationId;
  NotificationModel({
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    required this.userId,
    required this.updatedAt,
    required this.read,
    required this.notificationId,
  });

  NotificationModel copyWith({
    String? title,
    String? body,
    DateTime? createdAt,
    String? type,
    String? userId,
    DateTime? updatedAt,
    bool? read,
    String? notificationId,
  }) {
    return NotificationModel(
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      read: read ?? this.read,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'body': body,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type,
      'userId': userId,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'read': read,
      'notificationId ': notificationId,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is DateTime) return value;
      throw Exception('Invalid date type: \\${value.runtimeType}');
    }

    return NotificationModel(
      title: map['title'] as String? ??"",
      body: map['body'] as String? ?? "",
      createdAt: parseDate(map['createdAt']),
      type: map['type'] as String? ?? "",
      userId: map['userId'] as String? ??"",
      updatedAt: parseDate(map['updatedAt']),
      read: map['read'] as bool? ?? false,
      notificationId: map['notificationId'] as String? ??"",
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationModel(title: $title, body: $body, createdAt: $createdAt, type: $type, userId: $userId, updatedAt: $updatedAt, read:$read, notificationId :$notificationId)';
  }

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.body == body &&
        other.createdAt == createdAt &&
        other.type == type &&
        other.userId == userId &&
        other.updatedAt == updatedAt &&
        other.read == read &&
        other.notificationId == notificationId;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        body.hashCode ^
        createdAt.hashCode ^
        type.hashCode ^
        userId.hashCode ^
        updatedAt.hashCode ^
        read.hashCode ^
        notificationId.hashCode;
  }
}
