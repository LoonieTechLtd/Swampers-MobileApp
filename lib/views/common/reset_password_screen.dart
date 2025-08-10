import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/core/services/auth_services.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _resetPassword() async {
    if (emailController.text.isEmpty) return;

    bool success = await AuthServices().resetPassword(emailController.text);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Password reset email sent! Check your inbox.'
              : 'Failed to send reset email. Please try again.',
        ),
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              Center(
                child: Image.asset(
                  'assets/images/company_logo.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 60),
              Text(
                'Enter your email.',
                style: CustomTextStyles.h2.copyWith(
                  color: AppColors().primaryColor,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'We will sent an password reset link to your email.',
                style: CustomTextStyles.description,
              ),
              SizedBox(height: 20),
              Form(
                key: formKey,
                child: CustomTextfield(
                  hintText: "Your Email",
                  controller: emailController,
                  obscureText: false,
                  textInputType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your email address";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),
              CustomButton(
                backgroundColor: AppColors().primaryColor,
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  _resetPassword();
                },
                text: "Send Reset Link",
                textColor: AppColors().white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
