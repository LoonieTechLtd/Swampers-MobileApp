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

class CompanyEmailVerificationScreen extends ConsumerStatefulWidget {
  final String companyName;
  final String email;
  final String phone;
  final String address;
  final String password;
  final String profilePic;

  const CompanyEmailVerificationScreen({
    super.key,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
    required this.profilePic,
  });

  @override
  ConsumerState<CompanyEmailVerificationScreen> createState() =>
      _CompanyEmailVerificationScreenState();
}

class _CompanyEmailVerificationScreenState
    extends ConsumerState<CompanyEmailVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;

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
                    final result = await AuthServices().registerCompany(
                      widget.email,
                      widget.password,
                      widget.companyName,
                      widget.phone,
                      widget.address,
                      widget.profilePic,
                    );
                    if (!mounted) return;
                    if (result == "Success") {
                      showCustomSnackBar(
                        context: context,
                        message: "Company Registered Successfully",
                        backgroundColor: Colors.green,
                      );
                      final message = await AuthServices().login(
                        widget.email,
                        widget.password,
                      );
                      if (!mounted) return;
                      if (message == "Individual") {
                        context.go('/individual');
                      } else if (message == "Company") {
                        ref.invalidate(companyProvider);
                        ref.invalidate(kycStatusProvider);
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
