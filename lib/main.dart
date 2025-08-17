import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/firebase_options.dart';
import 'package:swamper_solution/routes/app_route_config.dart';
import 'package:swamper_solution/core/services/notificiation_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificiationServices.initilizeLocalNotifications();
  runApp(ProviderScope(child: MyApp()));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message received: ${message.notification?.title}');
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

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late final AppRouteConfig _appRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appRoute = AppRouteConfig();
    // Set up FCM
    _setupFCM();
    // Only rebuild on significant auth changes, not every state change
    User? lastUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted && lastUser?.uid != user?.uid) {
        lastUser = user;
        setState(() {});
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      NotificiationServices.showNotification(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('App lifecycle state changed to: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('App resumed from background');
        break;
      case AppLifecycleState.paused:
        debugPrint('App paused/went to background');
        break;
      case AppLifecycleState.detached:
        debugPrint('App detached');
        break;
      default:
        break;
    }
  }

  Future<void> _setupFCM() async {
    try {
      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token: $token');
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _appRoute.appRoutes.routeInformationParser,
      routeInformationProvider: _appRoute.appRoutes.routeInformationProvider,
      routerDelegate: _appRoute.appRoutes.routerDelegate,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          centerTitle: true,
          titleTextStyle: CustomTextStyles.title.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}
