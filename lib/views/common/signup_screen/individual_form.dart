import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/services/auth_services.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_drop_down.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';

class IndividualForm extends StatefulWidget {
  final WidgetRef ref;
  const IndividualForm({super.key, required this.ref});

  @override
  State<IndividualForm> createState() => _IndividualFormState();
}

class _IndividualFormState extends State<IndividualForm> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final List<String> workOptions = [
    "Warehouse Associates",
    "Lumping & Destuffing",
    "Constructions",
    "Factory Works",
    "Handy Man",
    "Cleaning",
    "Movers",
    "General Works",
    "Restaurant Service",
  ];

  bool isVisible = true;
  bool isLoading = false;
  String? selectedWork;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
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
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: CustomTextfield(
                    hintText: "First name",
                    controller: firstNameController,
                    obscureText: false,
                    textInputType: TextInputType.text,
                  ),
                ),
                Expanded(
                  child: CustomTextfield(
                    hintText: "Last name",
                    controller: lastNameController,
                    obscureText: false,
                    textInputType: TextInputType.text,
                  ),
                ),
              ],
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
                if (value!.length < 10) {
                  return "Invalid phone no";
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
                  return "Password must be more than 6 char long";
                }
                return null;
              },
            ),
            CustomDropDown(
              value: selectedWork,
              hintText: "Select your interested work",
              options: workOptions,
              onChanged: (value) {
                setState(() {
                  selectedWork = value;
                });
              },
            ),
            SizedBox(height: 40),

            // Signup button
            CustomButton(
              backgroundColor: AppColors().primaryColor,
              isLoading: isLoading,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (selectedWork == null) {
                  showCustomSnackBar(
                    context: context,
                    message: "Please select your interested work",
                    backgroundColor: Colors.red,
                  );
                  return;
                }

                setState(() {
                  isLoading = true;
                });

                try {
                  final result = await AuthServices().registerUser(
                    emailController.text.trim(),
                    passwordController.text,
                    firstNameController.text.trim(),
                    lastNameController.text.trim(),
                    phoneController.text.trim(),
                    addressController.text.trim(),
                    "https://i.pinimg.com/736x/87/14/55/8714556a52021ba3a55c8e7a3547d28c.jpg",
                    selectedWork!,
                  );

                  if (!mounted) return;

                  if (result == "Success") {
                    showCustomSnackBar(
                      context: context,
                      message:
                          "Account created! Please verify your email to continue.",
                      backgroundColor: Colors.green,
                    );
                    context.goNamed("email_varification_screen");
                  } else {
                    showCustomSnackBar(
                      context: context,
                      message: result ?? "Registration failed",
                      backgroundColor: Colors.red,
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  showCustomSnackBar(
                    context: context,
                    message: e.toString(),
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
              text: "Register Now",
              textColor: AppColors().white,
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
