import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/models/notification_model.dart';

class NotificationController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  //method to fetch user's notifications
  Stream<List<NotificationModel>> getUserNotification() {
    try {
      return firestore
          .collection("notifications")
          .doc(auth.currentUser!.uid)
          .collection("userNotifications")
          .orderBy("createdAt", descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return NotificationModel.fromMap(data);
            }).toList();
          });
    } catch (e) {
      debugPrint("Error fetching notifications: \\${e.toString()}");
      return Stream.value([]);
    }
  }

  //mark notification as read
  Future<void> toggleNotificationReadStatus(String notificationId ) async {
    try {
      final docRef = firestore
          .collection("notifications")
          .doc(auth.currentUser!.uid)
          .collection("userNotifications")
          .doc(notificationId);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final currentReadStatus = docSnapshot.data()?['read'] ?? false;

        await docRef.update({
          "read": !currentReadStatus,
        });
      } else {
        debugPrint("Notification document does not exist.");
      }
    } catch (e) {
      debugPrint("Failed to toggle notification read status: ${e.toString()}");
    }
  }
}
