import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:swamper_solution/models/message_model.dart';

class MessageController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // Method to send chat message to swamper
  Future<void> sendMessagetoSwamper(
    MessageModel message,
    String messageId,
  ) async {
    try {
      firestore.collection("messages").doc(messageId).set(message.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // method to fetch user's chat messages
  Stream<List<MessageModel>> getUserMessages(String uid) {
    try {
      final sent = firestore
          .collection("messages")
          .where("senderId", isEqualTo: uid)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => MessageModel.fromMap(doc.data()))
                    .toList(),
          );

      final received = firestore
          .collection("messages")
          .where("receiverId", isEqualTo: uid)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => MessageModel.fromMap(doc.data()))
                    .toList(),
          );

      return Rx.combineLatest2<
        List<MessageModel>,
        List<MessageModel>,
        List<MessageModel>
      >(sent, received, (a, b) {
        final allMessages = [...a, ...b];

        // Sort by sendAt descending (newest first), change to ascending if needed
        allMessages.sort((x, y) => x.sendAt.compareTo(y.sendAt));

        return allMessages;
      });
    } catch (e) {
      debugPrint("Error while fetching messages: ${e.toString()}");
      return Stream.value([]);
    }
  }
}
