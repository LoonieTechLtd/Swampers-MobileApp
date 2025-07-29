import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      sendVerificationEmail();

      // Check email verification status every 3 seconds
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();

      // Get user role and navigate to appropriate screen
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final userDoc =
              await FirebaseFirestore.instance
                  .collection('profiles')
                  .doc(user.uid)
                  .get();

          if (userDoc.exists) {
            final role = userDoc.data()?['role'] as String?;

            if (!mounted) return;

            if (role == 'Individual') {
              context.go('/individual');
            } else if (role == 'Company') {
              context.go('/company');
            } else {
              // Invalid role, show error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid user role. Please contact support.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error loading user profile. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      debugPrint("Failed to send verification email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
          appBar: AppBar(title: const Text('Email Verification')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_unread,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Check Your Email',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We\'ve sent a verification link to ${FirebaseAuth.instance.currentUser?.email ?? "your email"}. Please check your inbox and click the link to verify your account.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Once you click the verification link, you will be automatically redirected to the app.',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      await sendVerificationEmail();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification email sent!'),
                        ),
                      );
                    },
                    child: const Text('Resend Verification Email'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      context.go('/login');
                    },
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
