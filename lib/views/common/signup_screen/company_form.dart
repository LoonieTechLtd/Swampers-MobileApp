import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/core/services/auth_services.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';

class CompanyForm extends StatefulWidget {
  final WidgetRef ref;
  const CompanyForm({super.key, required this.ref});

  @override
  State<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isVisible = true;
  bool isLoading = false;
  @override
  void dispose() {
    companyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          spacing: 12,
          children: [
            CustomTextfield(
              hintText: "Company Name",
              controller: companyNameController,
              obscureText: false,
              textInputType: TextInputType.text,
            ),
            CustomTextfield(
              hintText: "Email",
              controller: emailController,
              obscureText: false,
              textInputType: TextInputType.text,
            ),
            CustomTextfield(
              hintText: "Contact no",
              controller: phoneController,
              obscureText: false,
              textInputType: TextInputType.number,
              validator: (value) {
                if (value!.trim().length != 10) {
                  return "Invalid Phone no";
                }
                return null;
              },
            ),
            CustomTextfield(
              hintText: "Address",
              controller: addressController,
              obscureText: false,
              textInputType: TextInputType.text,
            ),
            CustomTextfield(
              hintText: "Create password",
              controller: passwordController,
              obscureText: isVisible,
              onPressedSuffix: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },
              textInputType: TextInputType.text,
              suffixIcon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
              ),
              validator: (value) {
                if (value!.trim().length < 6) {
                  return "Password cannot be empty";
                }
                return null;
              },
            ),
            SizedBox(height: 30),

            // Signup button
            CustomButton(
              isLoading: isLoading,
              backgroundColor: Colors.blue,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (phoneController.text.length > 10) return;

                setState(() {
                  isLoading = true;
                });
                try {
                  debugPrint("Starting company registration process...");
                  debugPrint(
                    "Phone number entered: '${phoneController.text.trim()}'",
                  );

                  // Temporary debugging: List all existing phone numbers
                  final existingPhones =
                      await AuthServices().debugPhoneNumbers();
                  debugPrint(
                    "Existing phone numbers in database (${existingPhones.length} total):",
                  );
                  for (var phoneData in existingPhones) {
                    debugPrint(
                      "  ${phoneData['email']}: ${phoneData['originalPhone']} (normalized: ${phoneData['normalizedPhone']})",
                    );
                  }

                  final result = await AuthServices().registerCompany(
                    emailController.text.trim(),
                    passwordController.text,
                    companyNameController.text.trim(),
                    phoneController.text.trim(),
                    addressController.text.trim(),
                    "https://i.pinimg.com/736x/87/14/55/8714556a52021ba3a55c8e7a3547d28c.jpg",
                  );

                  debugPrint("Company registration result: $result");

                  if (!mounted) return;

                  if (result == "Success") {
                    showCustomSnackBar(
                      context: context,
                      message:
                          "Company account created! Please verify your email to continue.",
                      backgroundColor: Colors.green,
                    );
                    context.goNamed('email_varification_screen');
                  } else {
                    showCustomSnackBar(
                      context: context,
                      message: result ?? "Registration failed",
                      backgroundColor: Colors.red,
                    );
                  }
                } catch (e) {
                  debugPrint("Exception during company registration: $e");
                  showCustomSnackBar(
                    context: context,
                    message: "Registration error: ${e.toString()}",
                    backgroundColor: Colors.red,
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
              text: "Register Your Company",
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  Color backgroundColor = Colors.green,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
