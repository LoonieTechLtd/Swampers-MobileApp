import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/core/services/tokens_topics_services.dart';
import 'package:swamper_solution/firebase_options.dart';
import 'package:swamper_solution/routes/app_route_config.dart';
import 'package:swamper_solution/core/services/notificiation_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();

  // ensure apns key availability
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await Future.delayed(Duration(seconds: 1));
    try {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      debugPrint('Main APNS Token: $apnsToken');
    } catch (e) {
      debugPrint('Error getting APNS token in main: $e');
    }
  }

  FirebaseMessaging.onBackgroundMessage(TokensTopicsServices().firebaseMessagingBackgroundHandler);
  await NotificationServices.initializeLocalNotifications();
  runApp(ProviderScope(child: MyApp()));
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
    TokensTopicsServices().setupFCM();

    // Subscribe to topics for already authenticated users
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      TokensTopicsServices().subscribeToTopics(currentUser.uid);
    }

    User? lastUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted && lastUser?.uid != user?.uid) {
        // Handle user logout - unsubscribe from topics
        if (lastUser != null && user == null) {
          TokensTopicsServices().unsubscribeFromAllTopics();
        }
        lastUser = user;
        setState(() {});
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      debugPrint('Message data: ${message.data}');

      // Show notification when app is in foreground
      NotificationServices.showNotification(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message clicked: ${message.notification?.title}');
      // Handle navigation based on message data
      _handleNotificationTap(message);
    });

    // Check if app was opened from a notification
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        debugPrint(
          'App opened from notification: ${message.notification?.title}',
        );
        _handleNotificationTap(message);
      }
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

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Handling notification tap: ${message.data}');
    context.goNamed("notifications");
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
