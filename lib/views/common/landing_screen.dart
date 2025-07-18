import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              fit: BoxFit.contain,
              'assets/images/top_gradient.png',
              width: MediaQuery.of(context).size.width,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Text(
                    "WELCOME TO\nSWAMPER SOLUTIONS",
                    style: CustomTextStyles.h3.copyWith(
                      color: AppColors().primaryColor,
                    ),
                  ),
                  Text(
                    '"Your Gateway to Trusted Labor Solutions"',
                    style: CustomTextStyles.description.copyWith(
                      color: const Color.fromARGB(154, 33, 149, 243),
                    ),
                  ),
                  CustomButton(
                    backgroundColor: AppColors().primaryColor,
                    onPressed: () {
                      debugPrint('Log In button tapped');
                      context.go('/login');
                    },
                    text: "Log In",
                    textColor: Colors.white,
                  ),
                  CustomButton(
                    backgroundColor: AppColors().white,
                    onPressed: () {
                      debugPrint('Sign Up button tapped');
                      context.go('/signup');
                    },
                    text: "Sign Up",
                    textColor: AppColors().primaryColor,
                    haveBorder: true,
                    borderColor: AppColors().primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
