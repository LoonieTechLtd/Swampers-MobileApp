import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_model.dart';

class JobPostCard extends StatelessWidget {
  final JobModel jobDetails;
  final IndividualModel userDetails;

  const JobPostCard({super.key, required this.jobDetails, required this.userDetails});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/individual/job_details', extra: {
          'job': jobDetails,
          'user':userDetails
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: EdgeInsets.only(bottom: 18, left: 12, right: 12),
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
                    jobDetails.role,
                    style: CustomTextStyles.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "${jobDetails.hourlyIncome.toString()}\$",
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
                Text(jobDetails.location, style: CustomTextStyles.description),
              ],
            ),
            Row(
              children: [
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
              ],
            ),
            Text(
              jobDetails.description,
              style: CustomTextStyles.bodyText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
