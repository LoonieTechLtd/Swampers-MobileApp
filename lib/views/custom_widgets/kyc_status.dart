import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/individual_model.dart';

class KycStatus extends StatelessWidget {
  final IndividualModel data;
  final VoidCallback onTap;
  const KycStatus({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (data.kycVerified == "notSubmitted") {
      return StatusContainer(
        text: "KYC application not submitted",
        icon: FeatherIcons.userX,
        backgroundColor: Colors.black45,
        onTap: () {
          context.pushNamed("individual_kyc_application_screen");
        },
      );
    }
    if (data.kycVerified == "pending") {
      return StatusContainer(
        text: "KYC application is Pending",
        icon: FeatherIcons.clock,
        backgroundColor: Colors.green,
      );
    }
    if (data.kycVerified == "approved") {
      return StatusContainer(
        text: "KYC Verified",
        icon: FeatherIcons.userCheck,
        backgroundColor: AppColors().primaryColor,
      );
    }
    if (data.kycVerified == "rejected") {
      return StatusContainer(
        text: "KYC verification failed",
        icon: FeatherIcons.x,
        backgroundColor: AppColors().red,
      );
    }
    return StatusContainer(
      text: "Unknown KYC status",
      icon: FeatherIcons.helpCircle,
      backgroundColor: Colors.grey,
    );
  }
}

class StatusContainer extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;
  const StatusContainer({
    super.key,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors().white, size: 14),
            Text(
              text,
              style: CustomTextStyles.caption.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
