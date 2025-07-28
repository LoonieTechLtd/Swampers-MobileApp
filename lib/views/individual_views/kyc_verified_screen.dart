import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';

class KycVerifiedScreen extends StatelessWidget {
  const KycVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Due Diligence", textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    // Success checkmark icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Company logo
                    Image.asset(
                      "assets/images/company_logo.png",
                      height: 80,
                      width: 80,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Congratulations!",
                      style: CustomTextStyles.h2.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Your Due Diligence is Verified",
                      style: CustomTextStyles.h3,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "You can now apply for jobs and start working with Swamper.",
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 80),
              CustomButton(
                backgroundColor: AppColors().primaryColor,
                onPressed: () {
                  // Navigate back to main screen or dashboard
                  context.go('/individual');
                },
                text: "Continue to Dashboard",
                textColor: Colors.white,
              ),
              SizedBox(height: 16),
              CustomButton(
                backgroundColor: Colors.transparent,
                onPressed: () {
                  context.pushNamed("kyc_review");
                },
                text: "View KYC Details",
                textColor: AppColors().primaryColor,
                borderColor: AppColors().primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
