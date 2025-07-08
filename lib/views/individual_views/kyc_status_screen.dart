import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';

class KycStatusScreen extends StatelessWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KYC", textAlign: TextAlign.center),
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
                child: Image.asset(
                  "assets/images/company_logo.png",
                  height: 120,
                  width: 120,
                ),
              ),
              SizedBox(height: 40),
              Text(
                "You have submitted your KYC Application.",
                style: CustomTextStyles.h3,
              ),
              Text("Swamper will review and verify you shortly."),
              SizedBox(height: 80),
              CustomButton(
                backgroundColor: AppColors().primaryColor,
                onPressed: () {
                  context.pushNamed("kyc_review");
                },
                text: "Review your KYC",
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
