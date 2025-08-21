import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationServices {
  // final _firebaseMessaging = FirebaseMessaging.instance;
  static ReceivedAction? initialAction;

  // Future<void> initNotification() async {
  //   await _firebaseMessaging.requestPermission();
  //   final fcmToken = await _firebaseMessaging.getToken();
  //   debugPrint("FCM Token: $fcmToken");
  // }

  static Future<void> initilizeLocalNotifications() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'alerts',
        channelName: 'Alerts',
        channelDescription: 'Notification tests as alearts',
        playSound: true,
        onlyAlertOnce: true,
        groupAlertBehavior: GroupAlertBehavior.Children,
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Private,
        defaultColor: Colors.blue,
        ledColor: Colors.blue,
      ),
    ], debug: true);
    initialAction = await AwesomeNotifications().getInitialNotificationAction(
      removeFromActionEvents: false,
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().microsecondsSinceEpoch.remainder(100000),
        channelKey: 'alerts',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigText,
      ),
    );
  }

  void jobApprovedNotification() {
    showNotification(
      title: "Your Job is Accepted by Swamper",
      body:
          "The Job you recently posted has been accepted by Swamper Solutions",
    );
  }
}
