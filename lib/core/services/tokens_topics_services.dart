import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:swamper_solution/core/services/notificiation_services.dart';

class TokensTopicsServices {
  // save FCM token in database
  Future<void> _saveFCMToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance.collection('fcmtokens').doc(userId).set({
        'fcmToken': token,
        'userId': userId,
      });
      debugPrint('FCM token saved for user: $userId');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // to setup FCM token
  Future<void> setupFCM() async {
    try {
      // For iOS, get APNS token first
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          debugPrint('APNS Token: $apnsToken');
        } else {
          debugPrint('APNS token not available yet, will retry...');
          // Retry getting APNS token after a delay
          await Future.delayed(Duration(seconds: 3));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          debugPrint('APNS Token (retry): $apnsToken');
        }
      }

      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token: $token');
      if (token != null) {
        // Save token to user's profile when user is authenticated
        FirebaseAuth.instance.authStateChanges().listen((user) async {
          if (user != null) {
            await _saveFCMToken(user.uid, token);
            await subscribeToTopics(user.uid);
          }
        });
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _saveFCMToken(user.uid, newToken);
        }
      });
    } catch (e) {
      debugPrint('Error setting up FCM: $e');
    }
  }

  // to subscribe to topics when logged in
  Future<void> subscribeToTopics(String userId) async {
    try {
      // Get user profile to determine role
      final userDoc =
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(userId)
              .get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final userRole = userData?['role'] as String?;

        if (userRole != null) {
          String topic;
          if (userRole == 'Individual') {
            topic = 'users';
          } else if (userRole == 'Company') {
            topic = 'companies';
          } else {
            debugPrint('Unknown user role: $userRole');
            return;
          }

          // Subscribe to the appropriate topic
          await FirebaseMessaging.instance.subscribeToTopic(topic);
          debugPrint(
            'Successfully subscribed to topic: $topic for role: $userRole',
          );
        } else {
          debugPrint('User role not found in profile');
        }
      } else {
        debugPrint('User profile not found');
      }
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  // to unsubscribe from all the topics when sign out
  Future<void> unsubscribeFromAllTopics() async {
    try {
      // Unsubscribe from both possible topics
      await FirebaseMessaging.instance.unsubscribeFromTopic('users');
      await FirebaseMessaging.instance.unsubscribeFromTopic('companies');
      debugPrint('Successfully unsubscribed from all topics');
    } catch (e) {
      debugPrint('Error unsubscribing from topics: $e');
    }
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message received: ${message.notification?.title}');

  await NotificationServices.showNotification(
    title: message.notification?.title ?? 'Notification',
    body: message.notification?.body ?? '',
    payload: message.data.toString(),
  );
}
}
