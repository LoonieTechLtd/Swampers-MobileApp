// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String messageId;
  String message;
  String senderId;
  String receiverId;
  DateTime sendAt;
  bool isImage;

  MessageModel({
    required this.messageId,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.sendAt,
    required this.isImage,
  });

  MessageModel copyWith({
    String? messageId,
    String? message,
    String? senderId,
    String? receiverId,
    DateTime? sendAt,
    bool? isImage,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      sendAt: sendAt ?? this.sendAt,
      isImage: isImage ?? this.isImage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messageId': messageId,
      'message': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'sendAt': Timestamp.fromDate(sendAt), // Store as Firestore Timestamp
      'isImage': isImage,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] as String,
      message: map['message'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      sendAt:
          (map['sendAt'] is Timestamp)
              ? (map['sendAt'] as Timestamp).toDate()
              : DateTime.parse(map['sendAt'] as String),
      isImage: map['isImage'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MessageModel(messageId: $messageId, message: $message, senderId: $senderId, receiverId: $receiverId, sendAt: $sendAt, isImage: $isImage)';
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;

    return other.messageId == messageId &&
        other.message == message &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.sendAt == sendAt &&
        other.isImage == isImage;
  }

  @override
  int get hashCode {
    return messageId.hashCode ^
        message.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        sendAt.hashCode ^
        isImage.hashCode;
  }
}
