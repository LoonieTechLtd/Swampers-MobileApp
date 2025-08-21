// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

enum KycStatusEnum {
  notSubmitted(
    title: "Complete Due Diligence",
    description: "Get started now",
    icon: FeatherIcons.userX,
    color: Colors.black45,
  ),
  pending(
    title: "Due Diligence Under Review",
    description: "Review in progress",
    icon: FeatherIcons.clock,
    color: Colors.green,
  ),
  approved(
    title: "Due Diligence Verified",
    description: "Ready to apply for jobs",
    icon: FeatherIcons.userCheck,
    color: null, // Will use AppColors().primaryColor
  ),
  rejected(
    title: "Due Diligence Review Failed",
    description: "Action required",
    icon: FeatherIcons.x,
    color: null, // Will use AppColors().red
  );

  const KycStatusEnum({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color? color;

  factory KycStatusEnum.fromString(String status) {
    switch (status) {
      case "notSubmitted":
        return KycStatusEnum.notSubmitted;
      case "pending":
        return KycStatusEnum.pending;
      case "approved":
        return KycStatusEnum.approved;
      case "rejected":
        return KycStatusEnum.rejected;
      default:
        throw ArgumentError('Unknown KYC status: $status');
    }
  }

  Color getBackgroundColor() {
    switch (this) {
      case KycStatusEnum.approved:
        return AppColors().primaryColor;
      case KycStatusEnum.rejected:
        return AppColors().red;
      default:
        return color!;
    }
  }

  VoidCallback? getOnTap(BuildContext context) {
    switch (this) {
      case KycStatusEnum.notSubmitted:
        return () => context.goNamed("individual_kyc_application_screen");
      case KycStatusEnum.pending:
        return () => context.goNamed("kyc_review");
      case KycStatusEnum.rejected:
        return () => context.goNamed("edit_kyc");
      case KycStatusEnum.approved:
        return ()=> context.goNamed("verified_kyc_application_screen");
    }
  }
}

class KycStatusHome extends StatelessWidget {
  final String kycStatus;
  const KycStatusHome({super.key, required this.kycStatus});

  @override
  Widget build(BuildContext context) {
    try {
      final statusEnum = KycStatusEnum.fromString(kycStatus);
      return HomeStatusContainer(
        text: statusEnum.title,
        icon: statusEnum.icon,
        backgroundColor: statusEnum.getBackgroundColor(),
        onTap: statusEnum.getOnTap(context),
      );
    } catch (e) {
      return HomeStatusContainer(
        text: "Due Diligence Status Unknown",
        icon: FeatherIcons.helpCircle,
        backgroundColor: Colors.grey,
      );
    }
  }
}

class HomeStatusContainer extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;
  const HomeStatusContainer({
    super.key,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: _getGradientColors(),
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.5, color: Colors.white24),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: CustomTextStyles.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusDescription(),
                        style: CustomTextStyles.description.copyWith(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      FeatherIcons.chevronRight,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (backgroundColor == Colors.green) {
      return [
        Colors.green.shade600,
        Colors.green.shade500,
        Colors.green.shade400,
      ];
    } else if (backgroundColor == AppColors().primaryColor) {
      return [
        AppColors().primaryColor,
        AppColors().secondaryColor,
        AppColors().primaryColor.withOpacity(0.8),
      ];
    } else if (backgroundColor == AppColors().red) {
      return [
        AppColors().red.withOpacity(0.9),
        Colors.red.shade400,
        Colors.red.shade300,
      ];
    } else if (backgroundColor == Colors.black45) {
      return [Colors.grey.shade700, Colors.grey.shade600, Colors.grey.shade500];
    } else {
      return [
        backgroundColor.withOpacity(0.8),
        backgroundColor,
        backgroundColor.withOpacity(0.6),
      ];
    }
  }

  String _getStatusDescription() {
    if (backgroundColor == Colors.green) {
      return "Review in progress";
    } else if (backgroundColor == AppColors().primaryColor) {
      return "Ready to apply for jobs";
    } else if (backgroundColor == AppColors().red) {
      return "Action required";
    } else if (backgroundColor == Colors.black45) {
      return "Get started now";
    } else {
      return "Status unclear";
    }
  }
}
