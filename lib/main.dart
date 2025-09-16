import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/firebase_options.dart';
import 'package:swamper_solution/routes/app_route_config.dart';
import 'dart:io' show Platform;
import 'package:swamper_solution/core/services/notificiation_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ask for permission (especially for iOS)
  await FirebaseMessaging.instance.requestPermission();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications
  await NotificationServices.initilizeLocalNotifications();

  runApp(const ProviderScope(child: MyApp()));
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message received: ${message.notification?.title}');
  NotificationServices.showNotification(
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

    _setupFCM(); // Set up FCM

    // Listen for auth state changes and rebuild only on significant changes
    User? lastUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted && lastUser?.uid != user?.uid) {
        lastUser = user;
        setState(() {}); // Rebuild if user changes
      }
    });

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      NotificationServices.showNotification(
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
    // Additional handling based on state (if needed)
  }

  Future<void> _setupFCM() async {
  try {
    // iOS only: Wait for APNs token to become available
    if (Platform.isIOS) {
      String? apnsToken;
      int retries = 0;

      while (apnsToken == null && retries < 5) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('⏳ Waiting for APNs token... retrying in 2s');
          await Future.delayed(const Duration(seconds: 2));
          retries++;
        }
      }

      if (apnsToken == null) {
        debugPrint('⚠️ Failed to get APNs token after retries.');
      } else {
        debugPrint('✅ APNs token: $apnsToken');
      }
    }

    // 3. Now request FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      debugPrint('⚠️ FCM token is null');
      return;
    }

    debugPrint('✅ FCM token: $fcmToken');

    // 4. Save token to Firestore if user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _saveFCMToken(user.uid, fcmToken);
    }

    // 5. Listen for FCM token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('🔄 FCM token refreshed: $newToken');
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _saveFCMToken(currentUser.uid, newToken);
      }
    });
  } catch (e, stackTrace) {
    debugPrint('❌ Error setting up FCM: $e');
    debugPrint(stackTrace.toString());
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
