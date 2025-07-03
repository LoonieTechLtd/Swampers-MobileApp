import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/views/custom_widgets/applied_jobs_card.dart';

class PostedJobsCard extends StatelessWidget {
  final JobModel jobDetails;
  const PostedJobsCard({super.key, required this.jobDetails});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/company/posted_job_details', extra: jobDetails);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(width: 0.6, color: Colors.black26),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Row: Role + Hourly Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    jobDetails.role,
                    style: CustomTextStyles.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${jobDetails.hourlyIncome}\$",
                  style: CustomTextStyles.h4.copyWith(color: Colors.red),
                ),
                Text(
                  "/",
                  style: CustomTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w100,
                  ),
                ),
                const Text("hr"),
              ],
            ),

            const SizedBox(height: 4),

            /// Location Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(FeatherIcons.mapPin, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    jobDetails.location,
                    style: CustomTextStyles.description,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

  
            Row(
              children: [
                /// Make this scrollable horizontally
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          jobDetails.shifts.map((shift) {
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

                /// Applicants Count
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(FeatherIcons.users, size: 16),
                    const SizedBox(width: 4),
                    Text("20", style: CustomTextStyles.bodyText),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// Job Description and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    jobDetails.description,
                    style: CustomTextStyles.bodyText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                JobStatus(
                  status: jobDetails.jobStatus,
                  icon: _getStatusIcon(jobDetails.jobStatus),
                  backgroundColor: _getStatusColor(jobDetails.jobStatus),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Approved":
        return FeatherIcons.check;
      case "Pending":
        return FeatherIcons.clock;
      default:
        return FeatherIcons.x;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.blue;
      case "Pending":
        return Colors.green;
      default:
        return Colors.red;
    }
  }
}
