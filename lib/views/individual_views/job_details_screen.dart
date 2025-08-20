import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/apply_job_dialogue.dart';
import 'package:swamper_solution/views/custom_widgets/descriptionCard.dart';
import 'package:swamper_solution/views/custom_widgets/image_carousel.dart';
import 'package:swamper_solution/views/custom_widgets/info_card.dart';
import 'package:swamper_solution/views/custom_widgets/job_header.dart';
import 'package:swamper_solution/views/custom_widgets/shift_card.dart';

class JobDetailsScreen extends ConsumerWidget {
  final JobModel jobDetails;
  final IndividualModel userData;

  const JobDetailsScreen({
    super.key,
    required this.jobDetails,
    required this.userData,
  });

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  String _formatDateRange(String dateRangeString) {
    try {
      final parts = dateRangeString.split(' to ');
      if (parts.length != 2) return dateRangeString;

      final startDate = _parseDate(parts[0]);
      final endDate = _parseDate(parts[1]);

      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      final startMonth = months[startDate.month - 1];
      final startDay = startDate.day.toString().padLeft(2, '0');
      final endMonth = months[endDate.month - 1];
      final endDay = endDate.day.toString().padLeft(2, '0');

      return '$startMonth $startDay to $endMonth $endDay';
    } catch (e) {
      return dateRangeString; // Return original if parsing fails
    }
  }

  String _calculateTotalDays(String dateRangeString) {
    try {
      final parts = dateRangeString.split(' to ');
      if (parts.length != 2) return '';

      final startDate = _parseDate(parts[0]);
      final endDate = _parseDate(parts[1]);

      final difference = endDate.difference(startDate).inDays + 1;
      return '$difference day${difference == 1 ? '' : 's'}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController pageController = PageController();
    final ValueNotifier<int> currentPage = ValueNotifier<int>(0);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  return StreamBuilder<bool>(
                    stream: ref
                        .watch(jobControllerProvider)
                        .isJobSaved(jobDetails.jobId),
                    builder: (context, snapshot) {
                      final isSaved = snapshot.data ?? false;
                      return IconButton(
                        onPressed: () {
                          ref
                              .read(jobControllerProvider)
                              .saveJob(jobDetails.jobId);
                        },
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? Colors.blue : Colors.black,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildImageCarousel(
                      pageController,
                      currentPage,
                      jobDetails.images,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          buildJobHeader(jobDetails: jobDetails),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: buildInfoCard(
                                  "Workers",
                                  jobDetails.noOfWorkers.toString(),
                                  Icons.people,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: buildInfoCard(
                                  "Duration",
                                  _calculateTotalDays(jobDetails.days),
                                  Icons.timer,
                                  iconColor: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          buildInfoCard(
                            "Job Period",
                            _formatDateRange(jobDetails.days),
                            Icons.calendar_today,
                            iconColor: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          buildShiftsCard(jobDetails.shifts),
                          const SizedBox(height: 16),
                          buildDescriptionCard(
                            description: jobDetails.description,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            final haveAppliedToThisJob = ref.watch(
              haveAppliedThisJobProvider(jobDetails),
            );

            return haveAppliedToThisJob.when(
              data: (haveApplied) {
                if (haveApplied) {
                  // Show "Already Applied" button when user has already applied
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors().red,
                      
                      borderRadius: BorderRadius.circular(30)
                    ),
                    width: double.infinity,
                    height: 56,
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FeatherIcons.checkCircle,color: AppColors().white,),
                        Text("Already Applied", style: CustomTextStyles.h4.copyWith(color: AppColors().white)),
                      ],
                    ),
                  );
                } else {
                  // Show "Apply for this job" button when user hasn't applied yet
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ApplyJobDialogue().showApplyJobDialogue(
                          context,
                          jobDetails,
                          userData,
                          ref,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.work_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Apply for this job',
                            style: CustomTextStyles.description.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              error: (error, stack) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Error - Try Again',
                          style: CustomTextStyles.description.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.grey.shade600,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Loading...',
                          style: CustomTextStyles.description.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
