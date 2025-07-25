import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/services/auth_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileLogoutDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(isTablet ? 32 : 24),
          title: _buildTitle(isTablet),
          content: _buildContent(isTablet),
          actionsPadding: EdgeInsets.only(
            left: isTablet ? 32 : 24,
            right: isTablet ? 32 : 24,
            bottom: isTablet ? 24 : 16,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            _buildCancelButton(context, isTablet),
            _buildLogoutButton(context, ref, isTablet),
          ],
        );
      },
    );
  }

  static Widget _buildTitle(bool isTablet) {
    return Row(
      children: [
        Icon(Icons.logout, color: Colors.red, size: isTablet ? 28 : 24),
        const SizedBox(width: 12),
        Text(
          "Log Out?",
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static Widget _buildContent(bool isTablet) {
    return Text(
      "Are you sure you want to log out? You'll need to sign in again to access your account.",
      style: CustomTextStyles.description.copyWith(
        fontSize: isTablet ? 16 : 14,
      ),
    );
  }

  static Widget _buildCancelButton(BuildContext context, bool isTablet) {
    return TextButton(
      onPressed: () => context.pop(),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.blue),
        ),
      ),
      child: Text(
        "Cancel",
        style: TextStyle(
          color: Colors.blue,
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
    bool isTablet,
  ) {
    return ElevatedButton(
      onPressed: () => AuthServices().logout(context, ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.logout, size: isTablet ? 18 : 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            "Log Out",
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
