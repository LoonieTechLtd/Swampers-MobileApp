import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/core/services/auth_services.dart';
import 'package:swamper_solution/views/custom_widgets/auth_navigation_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/views/common/signup_screen/google_role_screen.dart';
import 'package:swamper_solution/views/custom_widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),

                Center(
                  child: Image.asset(
                    'assets/images/company_logo.png',
                    height: 180,
                    width: 180,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    Text(
                      "Login To ",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black87,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "Swamper",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.blue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CustomTextfield(
                        hintText: "Email",
                        controller: emailController,
                        obscureText: false,
                        textInputType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      CustomTextfield(
                        hintText: "Password",
                        controller: passwordController,
                        obscureText: !isVisible,
                        textInputType: TextInputType.text,
                        onPressedSuffix: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                        suffixIcon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        validator: (value) {
                          if (value!.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.push('/reset_password');
                      },
                      child: Text("Forget Password?"),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                CustomButton(
                  backgroundColor: Colors.blue,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      final message = await AuthServices().login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        ref,
                      );
                      if (message == "Individual") {
                        if (mounted) context.go('/individual');
                      } else if (message == "Company") {
                        if (mounted) context.go('/company');
                      } else if (message == "email-not-verified") {
                        if (mounted) {
                          context.goNamed('email_varification_screen');
                          showCustomSnackBar(
                            context: context,
                            message:
                                "Please verify your email address to continue",
                            backgroundColor: Colors.orange,
                          );
                        }
                      } else if (message == "signup") {
                        if (mounted) {
                          context.go('/signup');
                          showCustomSnackBar(
                            context: context,
                            message: "Please create an account first",
                            backgroundColor: Colors.orange,
                          );
                        }
                      } else {
                        showCustomSnackBar(
                          context: context,
                          message: message,
                          backgroundColor: Colors.red,
                        );
                        setState(() {
                          isLoading = false;
                        });
                      }
                    } catch (e) {
                      showCustomSnackBar(
                        context: context,
                        message: "Login failed. Please try again later.",
                        backgroundColor: Colors.red,
                      );
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  isLoading: isLoading,
                  text: "Log In",
                  textColor: Colors.white,
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Expanded(child: Divider()),
                      Text("OR"),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),

               Platform.isIOS?ElevatedButton.icon(
                icon: Icon(Icons.apple),
                onPressed: (){

                  
                }, label: Text("Login With Apple")): // Google login button
                GoogleSignInButton(
                  isLoading: isLoading,
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      final result = await AuthServices().loginWithGoogle(ref);

                      if (result is String) {
                        if (result == "Individual") {
                          if (mounted) context.go('/individual');
                        } else if (result == "Company") {
                          if (mounted) context.go('/company');
                        } else {
                          if (mounted) {
                            showCustomSnackBar(
                              context: context,
                              message: result,
                              backgroundColor: Colors.red,
                            );
                          }
                        }
                      } else if (result is Map) {
                        if (result["status"] == "new_user") {
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => GoogleSignInRoleScreen(
                                      uid: result["uid"],
                                      email: result["email"],
                                    ),
                              ),
                            );
                          }
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        showCustomSnackBar(
                          context: context,
                          message: "Failed to sign in with Google",
                          backgroundColor: Colors.red,
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                ),

                SizedBox(height: 40),
                AuthNavigationButton(
                  prefixText: "Don't have an account?",
                  buttonText: "Register",
                  onTap: () {
                    context.push('/signup');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
