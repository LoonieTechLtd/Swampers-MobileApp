import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/services/auth_services.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';

class IndividualEmailVerificationScreen extends ConsumerStatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNo;
  final String password;
  final String address;
  final String profilePic;
  final String interestedWork;
  const IndividualEmailVerificationScreen({
    super.key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNo,
    required this.password,
    required this.address,
    required this.profilePic,
    required this.interestedWork,
  });

  @override
  ConsumerState<IndividualEmailVerificationScreen> createState() =>
      _IndividualEmailVerificationScreenState();
}

class _IndividualEmailVerificationScreenState
    extends ConsumerState<IndividualEmailVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
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
                'Enter OTP.',
                style: CustomTextStyles.h2.copyWith(
                  color: AppColors().primaryColor,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'We have sent an OTP to ${widget.email}. Check your inbox!',
                style: CustomTextStyles.description,
              ),
              SizedBox(height: 20),
              Form(
                key: formKey,
                child: CustomTextfield(
                  hintText: "OTP here",
                  controller: otpController,
                  obscureText: false,
                  textInputType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter OTP first";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),
              CustomButton(
                isLoading: isLoading,
                backgroundColor: AppColors().primaryColor,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  setState(() {
                    isLoading = true;
                  });
                  bool verified = AuthServices().verifyOtp(
                    otpController.text,
                    context,
                  );
                  if (verified) {
                    // Register company only after OTP is verified
                    final result = await AuthServices().registerUser(
                      widget.email,
                      widget.password,
                      widget.firstName,
                      widget.lastName,
                      widget.phoneNo,
                      widget.address,
                      widget.profilePic,
                      widget.interestedWork,
                    );
                    if (!mounted) return;
                    if (result == "Success") {
                      showCustomSnackBar(
                        context: context,
                        message: "Profile Created Successfully",
                        backgroundColor: Colors.green,
                      );
                      final message = await AuthServices().login(
                        widget.email,
                        widget.password,
                      );
                      if (!mounted) return;
                      if (message == "Individual") {
                        ref.invalidate(individualProvider);
                        ref.invalidate(kycStatusProvider);
                        context.go('/individual');
                      } else if (message == "Company") {
                        context.go('/company');
                      } else {
                        showCustomSnackBar(
                          context: context,
                          message: message,
                          backgroundColor: Colors.red,
                        );
                      }
                    } else {
                      showCustomSnackBar(
                        context: context,
                        message: result ?? "Registration failed",
                        backgroundColor: Colors.red,
                      );
                    }
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                text: "Verify Email",
                textColor: AppColors().white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
