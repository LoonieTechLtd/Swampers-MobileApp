import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/models/notification_model.dart';

class NotificationController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;


// method to save user's notification
  Future<void> saveNotificationToDb(NotificationModel notification) async {
    try {
      await firestore
          .collection("notifications")
          .doc(auth.currentUser!.uid)
          .collection("userNotifications")
          .add(notification.toMap());
    } catch (e) {
      debugPrint("Failed to save Notification: ${e.toString()}");
    }
  }

  //method to fetch user's notifications
  Stream<List<NotificationModel>> getUserNotification() {
    try {
      return firestore
          .collection("notifications")
          .doc(auth.currentUser!.uid)
          .collection("userNotifications")
          .orderBy("timeStamp", descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return NotificationModel.fromMap(data);
            }).toList();
          });
    } catch (e) {
      debugPrint("Error fetching notifications: ${e.toString()}");
      return Stream.value([]);
    }
  }

  
}
