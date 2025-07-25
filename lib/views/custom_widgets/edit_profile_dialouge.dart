import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/user_controller.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';

class EditProfileDialouge {
  Future<dynamic> editProfileDialouge(
    BuildContext context,
    WidgetRef ref,
    dynamic userData, // Accepts IndividualModel or CompanyModel
    TextEditingController firstNameOrCompanyController, [
    TextEditingController? lastNameController,
    TextEditingController? phoneNumberController,
    TextEditingController? addressController,
  ]) {
    final ValueNotifier<XFile?> pickedFileNotifier = ValueNotifier(null);
    final bool isIndividual = userData is IndividualModel;
    final bool isCompany = userData is CompanyModel;

    // Validate userData type
    if (!isIndividual && !isCompany) {
      throw ArgumentError(
        'userData must be either IndividualModel or CompanyModel',
      );
    }

    // Get screen dimensions for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? screenWidth * 0.2 : 16,
            vertical: isTablet ? 40 : 20,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
              maxHeight: screenSize.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          FeatherIcons.edit3,
                          color: Colors.blue,
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Edit Profile",
                          style: CustomTextStyles.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 24 : 20,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          FeatherIcons.x,
                          color: Colors.grey.shade600,
                          size: isTablet ? 24 : 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24 : 20),
                    child: Column(
                      children: [
                        // Profile Picture Section
                        Container(
                          padding: EdgeInsets.all(isTablet ? 24 : 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  final picked = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 80,
                                  );
                                  if (picked != null) {
                                    pickedFileNotifier.value = picked;
                                  }
                                },
                                borderRadius: BorderRadius.circular(80),
                                child: ValueListenableBuilder<XFile?>(
                                  valueListenable: pickedFileNotifier,
                                  builder: (context, pickedFile, _) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.1),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: isTablet ? 70 : 60,
                                            backgroundColor: Colors.grey[100],
                                            child: ClipOval(
                                              child:
                                                  pickedFile != null
                                                      ? Image.file(
                                                        File(pickedFile.path),
                                                        width:
                                                            isTablet
                                                                ? 140
                                                                : 120,
                                                        height:
                                                            isTablet
                                                                ? 140
                                                                : 120,
                                                        fit: BoxFit.cover,
                                                      )
                                                      : CachedNetworkImage(
                                                        imageUrl:
                                                            userData.profilePic,
                                                        width:
                                                            isTablet
                                                                ? 140
                                                                : 120,
                                                        height:
                                                            isTablet
                                                                ? 140
                                                                : 120,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => Container(
                                                              color:
                                                                  Colors
                                                                      .grey[100],
                                                              child: Icon(
                                                                Icons.person,
                                                                size:
                                                                    isTablet
                                                                        ? 60
                                                                        : 50,
                                                                color:
                                                                    Colors
                                                                        .grey[400],
                                                              ),
                                                            ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => Container(
                                                              color:
                                                                  Colors
                                                                      .grey[100],
                                                              child: Icon(
                                                                Icons.person,
                                                                size:
                                                                    isTablet
                                                                        ? 60
                                                                        : 50,
                                                                color:
                                                                    Colors
                                                                        .grey[400],
                                                              ),
                                                            ),
                                                      ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                FeatherIcons.camera,
                                                color: Colors.white,
                                                size: isTablet ? 18 : 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Tap to change profile picture",
                                style: CustomTextStyles.description.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Form Fields
                        if (isIndividual) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: firstNameOrCompanyController,
                                  label: 'First Name',
                                  icon: FeatherIcons.user,
                                  isTablet: isTablet,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInputField(
                                  controller: lastNameController!,
                                  label: 'Last Name',
                                  icon: FeatherIcons.user,
                                  isTablet: isTablet,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildInputField(
                            controller: firstNameOrCompanyController,
                            label: 'Company Name',
                            icon: FeatherIcons.briefcase,
                            isTablet: isTablet,
                          ),
                        ],

                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: phoneNumberController!,
                          label: 'Phone Number',
                          icon: FeatherIcons.phone,
                          isTablet: isTablet,
                        ),

                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: addressController!,
                          label: 'Address',
                          icon: FeatherIcons.mapPin,
                          maxLines: 2,
                          isTablet: isTablet,
                        ),

                        const SizedBox(height: 30),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildButton(
                                text: "Cancel",
                                icon: FeatherIcons.x,
                                onPressed: () => context.pop(),
                                backgroundColor: Colors.grey.shade100,
                                textColor: Colors.grey.shade700,
                                isTablet: isTablet,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildButton(
                                text: "Save Changes",
                                icon: FeatherIcons.check,
                                onPressed: () async {
                                  // Validate required fields
                                  if (firstNameOrCompanyController.text
                                      .trim()
                                      .isEmpty) {
                                    _showErrorSnackBar(
                                      context,
                                      isIndividual
                                          ? 'First name is required'
                                          : 'Company name is required',
                                    );
                                    return;
                                  }

                                  if (isIndividual &&
                                      (lastNameController?.text
                                              .trim()
                                              .isEmpty ??
                                          true)) {
                                    _showErrorSnackBar(
                                      context,
                                      'Last name is required',
                                    );
                                    return;
                                  }

                                  if (phoneNumberController.text
                                      .trim()
                                      .isEmpty) {
                                    _showErrorSnackBar(
                                      context,
                                      'Phone number is required',
                                    );
                                    return;
                                  }

                                  if (addressController.text.trim().isEmpty) {
                                    _showErrorSnackBar(
                                      context,
                                      'Address is required',
                                    );
                                    return;
                                  }

                                  await _handleSave(
                                    context,
                                    ref,
                                    userData,
                                    firstNameOrCompanyController,
                                    lastNameController,
                                    phoneNumberController,
                                    addressController,
                                    pickedFileNotifier,
                                    isIndividual,
                                  );
                                },
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                isTablet: isTablet,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isTablet,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: CustomTextStyles.bodyText.copyWith(fontSize: isTablet ? 16 : 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: CustomTextStyles.description.copyWith(
            color: Colors.grey.shade600,
            fontSize: isTablet ? 14 : 12,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: isTablet ? 20 : 18),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isTablet ? 20 : 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required bool isTablet,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isTablet ? 18 : 16, color: textColor),
      label: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: backgroundColor == Colors.blue ? 2 : 0,
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 12,
          horizontal: isTablet ? 20 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor:
            backgroundColor == Colors.blue
                ? Colors.blue.withOpacity(0.3)
                : Colors.transparent,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(FeatherIcons.alertCircle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    dynamic userData,
    TextEditingController firstNameOrCompanyController,
    TextEditingController? lastNameController,
    TextEditingController? phoneNumberController,
    TextEditingController? addressController,
    ValueNotifier<XFile?> pickedFileNotifier,
    bool isIndividual,
  ) async {
    String finalProfilePicUrl = userData.profilePic;

    // Upload only if new image was selected
    if (pickedFileNotifier.value != null) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Updating profile...",
                    style: CustomTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final uploadedUrl = await UserController().uploadProfilePic(
        userData.uid,
        pickedFileNotifier.value!,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (uploadedUrl != null) {
        finalProfilePicUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(FeatherIcons.alertCircle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Failed to upload profile picture'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
    }

    if (isIndividual) {
      final updatedUser = userData.copyWith(
        firstName: firstNameOrCompanyController.text,
        lastName: lastNameController?.text,
        contactNo: phoneNumberController?.text,
        address: addressController?.text,
        profilePic: finalProfilePicUrl,
      );
      await UserController().updateIndividualProfile(updatedUser);
      ref.invalidate(individualProvider);
    } else {
      final updatedCompany = userData.copyWith(
        companyName: firstNameOrCompanyController.text,
        contactNo: phoneNumberController?.text,
        address: addressController?.text,
        profilePic: finalProfilePicUrl,
      );
      await UserController().updateCompanyProfile(updatedCompany);
      ref.invalidate(companyProvider);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(FeatherIcons.check, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Profile updated successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Close dialog
    context.pop();
  }
}
