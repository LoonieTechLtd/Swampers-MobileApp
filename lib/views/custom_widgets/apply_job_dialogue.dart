import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:random_string/random_string.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_application_controller.dart';
import 'package:swamper_solution/controllers/stats_controller.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';

class ApplyJobDiaogue {
  // Helper method to calculate hours from shift string
  double calculateShiftHours(String shift) {
    try {
      final parts = shift.split(" To ");
      if (parts.length != 2) {
        return 0.0;
      }

      final startTimeStr = parts[0].trim();
      final endTimeStr = parts[1].trim();

      final startTime = _parseTime(startTimeStr);
      final endTime = _parseTime(endTimeStr);

      if (startTime == null || endTime == null) {
        return 0.0;
      }

      int durationMinutes =
          endTime.hour * 60 +
          endTime.minute -
          (startTime.hour * 60 + startTime.minute);

      if (durationMinutes < 0) {
        durationMinutes += 24 * 60;
      }

      return durationMinutes / 60.0; // Convert to hours as double
    } catch (e) {
      return 0.0;
    }
  }

  // Helper method to parse time strings (e.g., "9:00 AM" -> TimeOfDay)
  TimeOfDay? _parseTime(String timeStr) {
    try {
      String cleanTimeStr = timeStr.trim();

      // Check if it contains AM/PM
      if (!cleanTimeStr.toUpperCase().contains('AM') &&
          !cleanTimeStr.toUpperCase().contains('PM')) {
        return null;
      }

      final parts = cleanTimeStr.split(" ");
      if (parts.length < 2) {
        return null;
      }

      final timePart = parts[0];
      final amPm =
          parts[parts.length - 1].toUpperCase(); // Get last part as AM/PM

      final timeParts = timePart.split(":");
      if (timeParts.length != 2) {
        return null;
      }

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (amPm == 'PM' && hour != 12) {
        hour += 12;
      } else if (amPm == "AM" && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  void showApplyJobDialouge(
    BuildContext context,
    JobModel jobDetails,
    IndividualModel userData,
    WidgetRef ref,
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
            bool canQuickApply =
                selectedShift != null &&
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

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors().primaryColor,
                      ),
                      label: Text(
                        "Quick Apply",
                        style: CustomTextStyles.bodyText.copyWith(
                          color: AppColors().white,
                        ),
                      ),
                      onPressed:
                          canQuickApply
                              ? () async {
                                setState(() {
                                  isLoading = true;
                                });
                                final quickApplicationResumeUrl =
                                    await JobApplicationController()
                                        .getQuickApplyResume();
                                if (quickApplicationResumeUrl == null ||
                                    quickApplicationResumeUrl.isEmpty) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  context.pop();

                                  showCustomSnackBar(
                                    context: context,
                                    message:
                                        "Upload One-Time resume to Quick Apply",
                                    backgroundColor: AppColors().red,
                                  );
                                  return;
                                }
                                final String applicationId = randomAlphaNumeric(
                                  10,
                                );

                                final JobApplicationModel applicationDetails =
                                    JobApplicationModel(
                                      applicationId: applicationId,
                                      jobDetails: jobDetails,
                                      applicantId:
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
                                      appliedDate: DateTime.now().toString(),
                                      selectedShift: selectedShift!,
                                      resume: quickApplicationResumeUrl,
                                      applicationStatus: "Pending",
                                      isQuickApplied: true
                                    );
                                final message = await JobApplicationController()
                                    .applyForJob(
                                      applicationDetails,
                                      applicationId,
                                    );
                                setState(() {
                                  isLoading = false;
                                });
                                if (message) {
                                  // Calculate total hours from the selected shift
                                  double shiftHours = calculateShiftHours(
                                    applicationDetails.selectedShift,
                                  );
                                  StatsController().updateIndividualStats(
                                    shiftHours,
                                    1,
                                  );
                                  showCustomSnackBar(
                                    context: context,
                                    message: "Job Applied Successfully",
                                    backgroundColor: Colors.green,
                                  );
                              ref.invalidate(haveAppliedThisJobProvider);

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
                    ),
                  ),

                  // PDF uploading button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
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
                        if (result != null &&
                            result.files.single.path != null) {
                          setState(() {
                            pickedFileName = result.files.single.name;
                            pickedFile = File(result.files.single.path!);
                          });
                        }
                      },
                    ),
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
                                  isQuickApplied: false
                                );
                            final message = await JobApplicationController()
                                .applyForJob(applicationDetails, applicationId);
                            setState(() {
                              isLoading = false;
                            });
                            if (message) {
                              // Calculate total hours from the selected shift
                              double shiftHours = calculateShiftHours(
                                applicationDetails.selectedShift,
                              );
                              StatsController().updateIndividualStats(
                                shiftHours,
                                1,
                              );
                              showCustomSnackBar(
                                context: context,
                                message: "Job Applied Successfully",
                                backgroundColor: Colors.green,
                              );
                              ref.invalidate(haveAppliedThisJobProvider);
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
