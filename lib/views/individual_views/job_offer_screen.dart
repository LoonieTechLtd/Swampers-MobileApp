import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/controllers/job_offers_controller.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/views/common/signup_screen/individual_form.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/descriptionCard.dart';
import 'package:swamper_solution/views/custom_widgets/image_carousel.dart';
import 'package:swamper_solution/views/custom_widgets/info_card.dart';
import 'package:swamper_solution/views/custom_widgets/job_header.dart';
import 'package:swamper_solution/views/custom_widgets/shift_card.dart';

class JobOfferScreen extends ConsumerWidget {
  final JobModel jobDetails;
  final IndividualModel userData;
  const JobOfferScreen({
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
      return dateRangeString;
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
          title: Text("Job Offer"),
          centerTitle: true,
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: CustomButton(
                  backgroundColor: AppColors().red,
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Reject the Job"),
                          content: Text(
                            "Are you sure want to reject this job? Once rejected cannot reapply",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: AppColors().primaryColor,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final res = await JobOffersController()
                                    .onJobOfferRejected(jobDetails, userData);
                                if (res == false) {
                                  showCustomSnackBar(
                                    context: context,
                                    message: "Failed to reject job",
                                    backgroundColor: AppColors().red,
                                  );
                                } else {
                                  showCustomSnackBar(
                                    context: context,
                                    message: "Job Rejected",
                                    backgroundColor: AppColors().green,
                                  );
                                }
                              },
                              child: Text(
                                "Reject Job",
                                style: TextStyle(color: AppColors().red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  text: "Reject Job",
                  textColor: AppColors().white,
                ),
              ),
              Expanded(
                child: CustomButton(
                  backgroundColor: AppColors().primaryColor,
                  onPressed: () async {
                    final res = await JobOffersController().onJobAccept(
                      userData,
                      jobDetails,
                    );
                    if (res == true) {
                      showCustomSnackBar(
                        context: context,
                        message: "Job Accepted Successfully",
                        backgroundColor: AppColors().green,
                      );
                    } else {
                      showCustomSnackBar(
                        context: context,
                        message: "Failed to accept Job",
                        backgroundColor: AppColors().red,
                      );
                    }
                  },
                  text: "Accept Job",
                  textColor: AppColors().white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
