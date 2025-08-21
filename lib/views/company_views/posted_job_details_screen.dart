import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:random_string/random_string.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_controller.dart';
import 'package:swamper_solution/controllers/stats_controller.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';
import 'package:swamper_solution/views/custom_widgets/day_range_selector.dart';
import 'package:swamper_solution/views/custom_widgets/time_range_selector.dart';
import 'package:swamper_solution/models/individual_model.dart'; // Import IndividualModel

class PostedJobDetailsScreen extends ConsumerStatefulWidget {
  final JobModel jobDetails;
  const PostedJobDetailsScreen(this.jobDetails, {super.key});

  @override
  ConsumerState<PostedJobDetailsScreen> createState() =>
      _PostedJobDetailsScreenState();
}

class _PostedJobDetailsScreenState
    extends ConsumerState<PostedJobDetailsScreen> {
  DateTimeRange? selectedDayRange;
  List<String> _timeRanges = [];
  String? dayRangeStr;

  @override
  void initState() {
    super.initState();
    // Initialize dayRangeStr and _timeRanges with existing job details
    dayRangeStr = widget.jobDetails.days;
    _timeRanges = List.from(widget.jobDetails.shifts);
  }

  // --- Helper Methods (Reused/Adapted from JobDetailsScreen) ---

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

  Future<void> _selectDayRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDateRange: selectedDayRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors().primaryColor,
            colorScheme: ColorScheme.light(primary: AppColors().primaryColor),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDayRange = picked;
        dayRangeStr =
            "${picked.start.day}/${picked.start.month}/${picked.start.year} to ${picked.end.day}/${picked.end.month}/${picked.end.year}";
      });
    }
  }

  Widget _buildImageCarousel(
    PageController pageController,
    ValueNotifier<int> currentPage,
  ) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: PageView.builder(
            controller: pageController,
            itemCount: widget.jobDetails.images.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.jobDetails.images[index],
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error, color: Colors.grey),
                        ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.jobDetails.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, page, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.jobDetails.images.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            page == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildJobHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.jobDetails.role,
                  style: CustomTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.jobDetails.location,
                  style: CustomTextStyles.bodyText.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon, {
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.blue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomTextStyles.description.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: CustomTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsCard(List<String> shifts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Shifts",
                style: CustomTextStyles.description.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                shifts.map((shift) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      shift,
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Job Description",
                style: CustomTextStyles.title.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.jobDetails.description,
            style: CustomTextStyles.bodyText.copyWith(
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedUsersSection() {
    final appliedUsersAsync = ref.watch(
      appliedUsersProvider(widget.jobDetails),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Applicants",
            style: CustomTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        appliedUsersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stackTrace) => Center(
                child: Text(
                  "Failed to load applicants: $error",
                  style: CustomTextStyles.bodyText.copyWith(color: Colors.red),
                ),
              ),
          data: (users) {
            if (users.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Center(
                  child: Text(
                    "No one has applied yet.",
                    style: CustomTextStyles.bodyText,
                  ),
                ),
              );
            }
            return Column(
              children: users.map((user) => _buildApplicantTile(user)).toList(),
            );
          },
        ),
      ],
    );
  }

  // --- NEW: Widget for a single applicant tile ---
  Widget _buildApplicantTile(IndividualModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: user.profilePic,
            imageBuilder:
                (context, imageProvider) =>
                    CircleAvatar(radius: 20, backgroundImage: imageProvider),
            placeholder:
                (context, url) => const CircleAvatar(
                  radius: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
            errorWidget:
                (context, url, error) => const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person, size: 30),
                ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: CustomTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: CustomTextStyles.caption.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  context.goNamed("edit_job", extra: widget.jobDetails);
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
                    _buildImageCarousel(pageController, currentPage),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildJobHeader(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  "Workers",
                                  widget.jobDetails.noOfWorkers.toString(),
                                  Icons.people,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  "Duration",
                                  _calculateTotalDays(widget.jobDetails.days),
                                  Icons.timer,
                                  iconColor: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            "Job Period",
                            _formatDateRange(widget.jobDetails.days),
                            Icons.calendar_today,
                            iconColor: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          _buildShiftsCard(widget.jobDetails.shifts),
                          const SizedBox(height: 16),
                          _buildDescriptionCard(),
                          const SizedBox(height: 16),
                          // --- ADDED: The new applicants section ---
                          _buildAppliedUsersSection(),
                          const SizedBox(height: 120), // Space for FAB
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  backgroundColor: AppColors().primaryColor, // Repost button
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setDialogState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
                                "Repost Job",
                                style: CustomTextStyles.h5,
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DayRangeSelector(
                                    selectedDayRange: selectedDayRange,
                                    dayRangeStr: dayRangeStr,
                                    onTap: () async {
                                      await _selectDayRange(context);
                                      setDialogState(() {});
                                    },
                                    onClear: () {
                                      setState(() {
                                        selectedDayRange = null;
                                        dayRangeStr = null;
                                      });
                                      setDialogState(() {});
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TimeRangeSelector(
                                    timeRanges: _timeRanges,
                                    onRangesUpdated: (updatedRanges) {
                                      setState(() {
                                        _timeRanges = updatedRanges;
                                      });
                                      setDialogState(() {});
                                    },
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
                                    style: TextStyle(color: AppColors().red),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (selectedDayRange == null ||
                                        _timeRanges.isEmpty) {
                                      if (!mounted) return;
                                      showCustomSnackBar(
                                        context: context,
                                        message: "Select Days and Shifts",
                                        backgroundColor: AppColors().red,
                                      );
                                      return;
                                    }
                                    if (!mounted) return;
                                    final jobId = randomAlphaNumeric(6);
                                    final msg = await JobController().repostJob(
                                      widget.jobDetails.copyWith(
                                        jobId: jobId,
                                        days: dayRangeStr,
                                        shifts: _timeRanges,
                                      ),
                                      jobId,
                                    );
                                    if (!mounted) return;
                                    if (msg == true) {
                                      context.pop();
                                      showCustomSnackBar(
                                        context: context,
                                        message: "Job reposted Successfully",
                                        backgroundColor:
                                            AppColors().primaryColor,
                                      );
                                    } else {
                                      showCustomSnackBar(
                                        context: context,
                                        message: "Failed to repost the Job",
                                        backgroundColor: AppColors().red,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors().primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Repost"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  text: "Repost",
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  backgroundColor: AppColors().red,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text(
                            "Delete Job?",
                            style: CustomTextStyles.h5,
                          ),
                          content: const Text(
                            "Are you sure you want to delete this job?",
                            style: CustomTextStyles.bodyText,
                          ),
                          actionsAlignment: MainAxisAlignment.end,
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
                              onPressed: () => _onDeleteJob(context),
                              child: Text(
                                "Delete",
                                style: TextStyle(color: AppColors().red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  text: "Delete",
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDeleteJob(BuildContext context) async {
    // Pop the dialog first
    Navigator.of(context).pop();

    final message = await JobController().deleteJob(
      widget.jobDetails.jobId,
      context,
    );
    if (!mounted) return;
    if (message == true) {
      showCustomSnackBar(
        context: context,
        message: "Job deleted",
        backgroundColor: Colors.green,
      );
      final statsUpdated = await StatsController().updateCompanyStats(
        widget.jobDetails.noOfWorkers,
        1,
        true,
      );

      if (!statsUpdated) {
        debugPrint("Warning: Failed to update company stats");
      }
      context.pop();
    } else {
      showCustomSnackBar(
        context: context,
        message: "Failed to delete job",
        backgroundColor: Colors.red,
      );
    }
  }
}
