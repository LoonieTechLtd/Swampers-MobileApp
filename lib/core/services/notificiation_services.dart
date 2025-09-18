import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationServices {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static NotificationAppLaunchDetails? initialAction;

  static Future<void> initializeLocalNotifications() async {
    try {
      debugPrint('Initializing local notifications...');

      // Initialize settings for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Initialize settings for iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Combine platform-specific settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      // Initialize the plugin
      final bool? initialized = await _flutterLocalNotificationsPlugin
          .initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: _onNotificationTap,
          );

      debugPrint('Local notifications initialized: $initialized');

      // Request permissions for iOS
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // Request permissions for Android 13+
      final bool? androidPermissionGranted =
          await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission();

      debugPrint(
        'Android notification permission granted: $androidPermissionGranted',
      );

      // Get initial notification if app was launched by tapping a notification
      initialAction =
          await _flutterLocalNotificationsPlugin
              .getNotificationAppLaunchDetails();
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTap(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');
    // You can add navigation logic here if needed
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (_flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >() !=
        null) {
      final bool? granted =
          await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()!
              .areNotificationsEnabled();
      return granted ?? false;
    }

    if (_flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >() !=
        null) {
      final bool? granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()!
          .requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    return false;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    try {
      debugPrint('Attempting to show notification: $title - $body');

      // Check if notifications are enabled
      final bool notificationsEnabled = await areNotificationsEnabled();
      if (!notificationsEnabled) {
        return;
      }

      // Android notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'alerts', // Channel ID
            'Alerts', // Channel name
            channelDescription: 'Notification tests as alerts',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            color: Colors.blue,
            // Remove LED configuration to avoid compatibility issues
            styleInformation: BigTextStyleInformation(''),
          );

      // iOS notification details
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      // Combine platform-specific details
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Generate unique notification ID
      int notificationId = DateTime.now().microsecondsSinceEpoch.remainder(
        100000,
      );

      // Show the notification
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
      );

      debugPrint('Notification sent with ID: $notificationId');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
}
