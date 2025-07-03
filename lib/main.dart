import 'package:email_otp/email_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  NotificiationServices.showNotification(
    title: message.notification!.title.toString(),
    body: message.notification!.body.toString(),
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

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {});
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificiationServices.showNotification(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    });
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
