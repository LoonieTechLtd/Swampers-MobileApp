import 'package:email_otp/email_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/firebase_options.dart';
import 'package:swamper_solution/routes/app_route_config.dart';
import 'package:swamper_solution/services/notificiation_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificiationServices.initilizeLocalNotifications();
  EmailOTP.config(
    appName: 'Swamper Solution',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v4,
  );
  runApp(ProviderScope(child: MyApp()));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.notification?.title}');
  NotificiationServices.showNotification(
    title: message.notification?.title ?? 'Notification',
    body: message.notification?.body ?? '',
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppRouteConfig _appRoute;

  @override
  void initState() {
    super.initState();
    _appRoute = AppRouteConfig();
    // Set up FCM
    _setupFCM();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {});
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');
      NotificiationServices.showNotification(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    });
  }

  Future<void> _setupFCM() async {
    try {
      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      if (token != null) {
        // Save token to user's profile when user is authenticated
        FirebaseAuth.instance.authStateChanges().listen((user) async {
          if (user != null) {
            await _saveFCMToken(user.uid, token);
          }
        });
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _saveFCMToken(user.uid, newToken);
        }
      });
    } catch (e) {
      print('Error setting up FCM: $e');
    }
  }

  Future<void> _saveFCMToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .update({'fcmToken': token});
      print('FCM token saved for user: $userId');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _appRoute.appRoutes.routeInformationParser,
      routeInformationProvider: _appRoute.appRoutes.routeInformationProvider,
      routerDelegate: _appRoute.appRoutes.routerDelegate,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          titleTextStyle: CustomTextStyles.title.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}
