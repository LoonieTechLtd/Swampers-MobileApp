import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/controllers/user_controller.dart';
import 'package:swamper_solution/views/common/signup_screen/individual_form.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';

class DeleteCompanyAccountScreen extends StatelessWidget {
  const DeleteCompanyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Account')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.no_accounts_outlined,
                      size: 80,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Delete Account',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Are you sure you want to delete your account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This action cannot be undone. Deleting your account will:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text('• Permanently remove all your data'),
                          SizedBox(height: 8),
                          Text('• Delete your profile and preferences'),
                          SizedBox(height: 8),
                          Text('• Remove access to all features'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  backgroundColor: AppColors().red,
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                  text: "Delete Account",
                  textColor: AppColors().white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final userController = UserController();
    final authProvider = userController.getUserAuthProvider();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    authProvider == 'google.com'
                        ? 'Please confirm with Google to delete your account:'
                        : 'Please enter your password to confirm account deletion:',
                  ),
                  const SizedBox(height: 16),
                  if (authProvider != 'google.com')
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  if (authProvider == 'google.com')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You\'ll be prompted to sign in with Google to confirm.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                // Validate password for email/password users
                                if (authProvider != 'google.com' &&
                                    passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter your password',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                final success = await userController
                                    .deleteAccount(
                                      context,
                                      ref,
                                      authProvider == 'google.com'
                                          ? null
                                          : passwordController.text,
                                    );

                                if (!success && context.mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  showCustomSnackBar(
                                    context: context,
                                    message:
                                        authProvider == 'google.com'
                                            ? "Failed to delete account. Google authentication required."
                                            : "Failed to delete account. Check your password",
                                    backgroundColor: AppColors().red,
                                  );
                                } else {
                                  showCustomSnackBar(
                                    context: context,
                                    message: "Account Deleted Successfully !",
                                    backgroundColor: AppColors().red,
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors().red,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text('Delete'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
