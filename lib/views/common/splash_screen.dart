import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      try {
        // Get user role from Firestore
        final userDoc =
            await FirebaseFirestore.instance
                .collection('profiles')
                .doc(auth.currentUser!.uid)
                .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role'] as String?;
          if (role == 'Individual') {
            if (mounted) context.go('/individual');
          } else if (role == 'Company') {
            if (mounted) context.go('/company');
          } else {
            // Invalid role, logout and go to landing
            await auth.signOut();
            if (mounted) context.go('/');
          }
        } else {
          // Profile not found, logout and go to landing
          await auth.signOut();
          if (mounted) context.go('/');
        }
      } catch (e) {
        // Error occurred, logout and go to landing
        await auth.signOut();
        if (mounted) context.go('/');
      }
    } else {
      // User not logged in, go to landing
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            SizedBox(width: mq.width, height: mq.height * 0.35),
            Image.asset(
              "assets/images/company_logo.png",
              height: 140,
              width: 140,
            ),
            Spacer(),
            Text(
              "Designed and Developed by,",
              style: CustomTextStyles.lightText,
            ),
            Text(
              "Loonie Tech Pvt Ltd",
              style: CustomTextStyles.h6.copyWith(
                color: AppColors().primaryColor,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
