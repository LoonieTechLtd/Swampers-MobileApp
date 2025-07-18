import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:random_string/random_string.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_application_controller.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';

class ApplyJobDiaogue {
  void showApplyJobDialouge(
    BuildContext context,
    JobModel jobDetails,
    IndividualModel userData,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedShift;
        String? pickedFileName;
        File? pickedFile;
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            bool canApply =
                selectedShift != null &&
                pickedFile != null &&
                userData.kycVerified == "approved" &&
                !isLoading;
            return AlertDialog(
              title: Text("Apply for this Job"),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedShift,
                    hint: const Text("Choose a shift"),
                    items:
                        jobDetails.shifts.map((shift) {
                          return DropdownMenuItem<String>(
                            value: shift,
                            child: Text(shift),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedShift = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // PDF uploading button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      pickedFileName ?? "Attach Resume (PDF)",
                      style: CustomTextStyles.bodyText,
                    ),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );
                      if (result != null && result.files.single.path != null) {
                        setState(() {
                          pickedFileName = result.files.single.name;
                          pickedFile = File(result.files.single.path!);
                        });
                      }
                    },
                  ),
                  Text("* The Resume Size must be less than 5MB."),
                  if (userData.kycVerified != "approved")
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        "Verify your KYC to apply for Job",
                        style: TextStyle(color: AppColors().red, fontSize: 14),
                      ),
                    ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text(
                    "Cancel",
                    style: CustomTextStyles.description.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                      canApply
                          ? () async {
                            setState(() {
                              isLoading = true;
                            });
                            final String applicationId = randomAlphaNumeric(10);
                            final String? resumeUrl =
                                await JobApplicationController()
                                    .uploadResumeToFirebase(
                                      pickedFile!,
                                      pickedFileName!,
                                    );
                            if (resumeUrl == null) {
                              setState(() {
                                isLoading = false;
                              });
                              showCustomSnackBar(
                                context: context,
                                message: "Failed to upload resume. Try again.",
                                backgroundColor: Colors.red,
                              );
                              return;
                            }
                            final JobApplicationModel applicationDetails =
                                JobApplicationModel(
                                  applicationId: applicationId,
                                  jobDetails: jobDetails,
                                  applicantId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  appliedDate: DateTime.now().toString(),
                                  selectedShift: selectedShift!,
                                  resume: resumeUrl,
                                  applicationStatus: "Pending",
                                );
                            final message = await JobApplicationController()
                                .applyForJob(applicationDetails, applicationId);
                            setState(() {
                              isLoading = false;
                            });
                            if (message) {
                              showCustomSnackBar(
                                context: context,
                                message: "Job Applied Successfully",
                                backgroundColor: Colors.green,
                              );
                              context.pop();
                            } else {
                              showCustomSnackBar(
                                context: context,
                                message: "Failed to apply Job, Try Again",
                                backgroundColor: Colors.red,
                              );
                              context.pop();
                            }
                          }
                          : null,
                  child:
                      isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            "Apply Now",
                            style: CustomTextStyles.description.copyWith(
                              color: canApply ? Colors.blue : Colors.grey,
                            ),
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
