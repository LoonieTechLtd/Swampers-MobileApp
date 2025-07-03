import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_application_controller.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/views/common/signup_screen/individual_form.dart';

class AppliedJobsCard extends StatelessWidget {
  final JobApplicationModel jobApplicationDetails;
  const AppliedJobsCard({super.key, required this.jobApplicationDetails});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(width: 0.6, color: Colors.black26),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    jobApplicationDetails.jobDetails.role,
                    style: CustomTextStyles.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "${jobApplicationDetails.jobDetails.hourlyIncome.toString()}\$",
                  style: CustomTextStyles.h4.copyWith(color: Colors.red),
                ),
                Text(
                  "/",
                  style: CustomTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w100,
                  ),
                ),
                Text("hr"),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [
                Icon(FeatherIcons.mapPin, size: 14),
                Text(
                  jobApplicationDetails.jobDetails.location,
                  style: CustomTextStyles.description,
                ),
              ],
            ),
            Row(
              children: [
                /// Make this scrollable horizontally
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          jobApplicationDetails.jobDetails.shifts.map((shift) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
                              ),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                shift,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    jobApplicationDetails.jobDetails.description,
                    style: CustomTextStyles.bodyText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                if (jobApplicationDetails.applicationStatus == "Approved") ...[
                  JobStatus(
                    status: "Approved",
                    icon: FeatherIcons.check,
                    backgroundColor: Colors.blue,
                  ),
                ] else if (jobApplicationDetails.applicationStatus ==
                    "Pending") ...[
                  JobStatus(
                    status: "Pending",
                    icon: FeatherIcons.clock,
                    backgroundColor: Colors.green,
                  ),
                ] else ...[
                  JobStatus(
                    status: "Rejected",
                    icon: FeatherIcons.x,
                    backgroundColor: Colors.red,
                  ),
                ],
              ],
            ),

            // Delete button in the Job Application Card
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors().red,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Delete Job Application",
                        style: TextStyle(color: Colors.red),
                      ),
                      content: Text(
                        "Are you sure you want to delete your job application?",
                      ),
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            final message = await JobApplicationController()
                                .deleteJobApplication(jobApplicationDetails);
                            if (message) {
                              context.pop();
                              showCustomSnackBar(
                                context: context,
                                message: "Job Application deleted.",
                                backgroundColor: AppColors().green,
                              );
                            } else {
                              context.pop();
                              showCustomSnackBar(
                                context: context,
                                message: "Failed to delete Job Application",
                                backgroundColor: AppColors().red,
                              );
                            }
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(FeatherIcons.trash2, color: Colors.white),
                  Text(
                    "Delete my Application",
                    style: CustomTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobStatus extends StatelessWidget {
  final String status;
  final IconData icon;
  final Color backgroundColor;
  const JobStatus({
    super.key,
    required this.status,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(status, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
