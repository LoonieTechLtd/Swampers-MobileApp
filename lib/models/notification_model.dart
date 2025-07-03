import 'dart:convert';

class NotificationModel {
  final String notificationId;
  final String uid;
  final String title;
  final String description;
  final DateTime timeStamp;
  NotificationModel({
    required this.notificationId,
    required this.uid,
    required this.title,
    required this.description,
    required this.timeStamp,
  });

  NotificationModel copyWith({
    String? notificationId,
    String? uid,
    String? title,
    String? description,
    DateTime? timeStamp,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notificationId': notificationId,
      'uid': uid,
      'title': title,
      'description': description,
      'timeStamp': timeStamp.millisecondsSinceEpoch,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] as String,
      uid: map['uid'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      timeStamp: DateTime.fromMillisecondsSinceEpoch(map['timeStamp'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) => NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationModel(notificationId: $notificationId, uid: $uid, title: $title, description: $description, timeStamp: $timeStamp)';
  }

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.notificationId == notificationId &&
      other.uid == uid &&
      other.title == title &&
      other.description == description &&
      other.timeStamp == timeStamp;
  }

  @override
  int get hashCode {
    return notificationId.hashCode ^
      uid.hashCode ^
      title.hashCode ^
      description.hashCode ^
      timeStamp.hashCode;
  }
}
