import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/core/services/auth_services.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';

class ChangePasswordDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final ValueNotifier<bool> isLoading = ValueNotifier(false);
    final ValueNotifier<bool> obscureCurrentPassword = ValueNotifier(true);
    final ValueNotifier<bool> obscureNewPassword = ValueNotifier(true);
    final ValueNotifier<bool> obscureConfirmPassword = ValueNotifier(true);

    // Get screen dimensions for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(isTablet ? 32 : 24),
          title: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: Colors.blue,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: 12),
              Text(
                "Change Password",
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current Password Field
                  ValueListenableBuilder<bool>(
                    valueListenable: obscureCurrentPassword,
                    builder: (context, obscure, child) {
                      return CustomTextfield(
                        controller: currentPasswordController,
                        hintText: "Current Password",
                        obscureText: obscure,
                        textInputType: TextInputType.text,
                        suffixIcon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressedSuffix: () {
                          obscureCurrentPassword.value = !obscure;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16),

                  // New Password Field
                  ValueListenableBuilder<bool>(
                    valueListenable: obscureNewPassword,
                    builder: (context, obscure, child) {
                      return CustomTextfield(
                        controller: newPasswordController,
                        hintText: "New Password",
                        obscureText: obscure,
                        textInputType: TextInputType.text,
                        suffixIcon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressedSuffix: () {
                          obscureNewPassword.value = !obscure;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16),

                  // Confirm Password Field
                  ValueListenableBuilder<bool>(
                    valueListenable: obscureConfirmPassword,
                    builder: (context, obscure, child) {
                      return CustomTextfield(
                        controller: confirmPasswordController,
                        hintText: "Confirm New Password",
                        obscureText: obscure,
                        textInputType: TextInputType.text,
                        suffixIcon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressedSuffix: () {
                          obscureConfirmPassword.value = !obscure;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),

                  // Password requirements text
                  Text(
                    "• Password must be at least 6 characters\n• Make sure to remember your new password",
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: EdgeInsets.only(
            left: isTablet ? 32 : 24,
            right: isTablet ? 32 : 24,
            bottom: isTablet ? 24 : 16,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Change Password Button
            ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, child) {
                return ElevatedButton(
                  onPressed:
                      loading
                          ? null
                          : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            isLoading.value = true;

                            try {
                              final result = await AuthServices()
                                  .changePassword(
                                    currentPasswordController.text,
                                    newPasswordController.text,
                                  );

                              if (!context.mounted) return;

                              if (result == "Success") {
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Password changed successfully!",
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                context.pop();
                              } else {
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } finally {
                              isLoading.value = false;
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 20,
                      vertical: isTablet ? 16 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      loading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check,
                                size: isTablet ? 18 : 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Change Password",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
