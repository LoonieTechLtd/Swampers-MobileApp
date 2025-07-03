import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/user_controller.dart';
import 'package:swamper_solution/models/individual_model.dart';
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

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors().white,
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular avatar to change profile picture
                InkWell(
                  onTap: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      pickedFileNotifier.value = picked;
                    }
                  },
                  child: ValueListenableBuilder<XFile?>(
                    valueListenable: pickedFileNotifier,
                    builder: (context, pickedFile, _) {
                      return CircleAvatar(
                        backgroundImage:
                            pickedFile != null
                                ? FileImage(
                                  File(pickedFile.path),
                                ) // Show picked image immediately
                                : CachedNetworkImageProvider(
                                      userData.profilePic,
                                    )
                                    as ImageProvider, // Show current profile pic
                        radius: 60,
                      );
                    },
                  ),
                ),
                Text(
                  "Tap to change profile picture",
                  style: CustomTextStyles.caption,
                ),
                SizedBox(height: 20),
                if (isIndividual) ...[
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: firstNameOrCompanyController,
                          decoration: InputDecoration(labelText: 'First Name'),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: lastNameController,
                          decoration: InputDecoration(labelText: 'Last Name'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  TextField(
                    controller: firstNameOrCompanyController,
                    decoration: InputDecoration(labelText: 'Company Name'),
                  ),
                ],
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 12,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors().red,
                        ),
                        onPressed: () {
                          context.pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: AppColors().white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors().primaryColor,
                        ),
                        onPressed: () async {
                          String finalProfilePicUrl = userData.profilePic;
                          // Upload only if new image was selected
                          if (pickedFileNotifier.value != null) {
                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 20),
                                      Text("Updating profile..."),
                                    ],
                                  ),
                                );
                              },
                            );

                            final uploadedUrl = await UserController()
                                .uploadProfilePic(
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
                                  content: Text(
                                    'Failed to upload profile picture',
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
                            await UserController().updateIndividualProfile(
                              updatedUser,
                            );
                            ref.invalidate(individualProvider);
                          } else {
                            final updatedCompany = userData.copyWith(
                              companyName: firstNameOrCompanyController.text,
                              contactNo: phoneNumberController?.text,
                              address: addressController?.text,
                              profilePic: finalProfilePicUrl,
                            );
                            await UserController().updateCompanyProfile(
                              updatedCompany,
                            );
                            ref.invalidate(companyProvider);
                          }
                          // Close dialog
                          context.pop();
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(color: AppColors().white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
