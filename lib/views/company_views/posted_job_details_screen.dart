import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_controller.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';
import 'package:swamper_solution/views/custom_widgets/day_range_selector.dart';
import 'package:swamper_solution/views/custom_widgets/time_range_selector.dart';

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
  List<String> shifts = [];
  String? dayRangeStr;

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    final ValueNotifier<int> currentPage = ValueNotifier<int>(0);
    Future<void> selectDayRange(BuildContext context) async {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        initialDateRange: selectedDayRange,
      );

      if (picked != null) {
        setState(() {
          selectedDayRange = picked;
          dayRangeStr =
              "${picked.start.day}/${picked.start.month}/${picked.start.year} to ${picked.end.day}/${picked.end.month}/${picked.end.year}";
        });
      }
    }

    Widget spacedDivider() => const Divider(thickness: 1.0, height: 24);

    Widget sectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 4),
        child: Text(title, style: CustomTextStyles.title),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Job Details"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.goNamed("edit_job", extra: widget.jobDetails);
            },
            child: Text(
              "Edit Job",
              style: CustomTextStyles.h5.copyWith(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.36,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: widget.jobDetails.images.length,
                    onPageChanged: (index) => currentPage.value = index,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          placeholder:
                              (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                          imageUrl: widget.jobDetails.images[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.jobDetails.role,
                        style: CustomTextStyles.h3,
                      ),
                    ),
                    Text(
                      "\$ ${widget.jobDetails.hourlyIncome}",
                      style: CustomTextStyles.h3.copyWith(color: Colors.red),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      "/",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text("hr", style: CustomTextStyles.description),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded),
                    const SizedBox(width: 6),
                    Text(
                      widget.jobDetails.location,
                      style: CustomTextStyles.bodyText,
                    ),
                  ],
                ),
                spacedDivider(),
                sectionTitle("No of Workers"),
                Text(
                  widget.jobDetails.noOfWorkers.toString(),
                  style: CustomTextStyles.bodyText,
                ),
                spacedDivider(),
                sectionTitle("Shifts"),
                ...widget.jobDetails.shifts.map(
                  (shift) => Text(shift, style: CustomTextStyles.bodyText),
                ),
                spacedDivider(),
                sectionTitle("Job descriptions"),
                Text(
                  widget.jobDetails.description,
                  style: CustomTextStyles.bodyText,
                ),
                spacedDivider(),
                const SizedBox(height: 12),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: CustomButton(
                        backgroundColor: Colors.blue,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setDialogState) {
                                  return AlertDialog(
                                    title: Text("Job Repost"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DayRangeSelector(
                                          selectedDayRange: selectedDayRange,
                                          dayRangeStr: dayRangeStr,
                                          onTap: () {
                                            selectDayRange(context).then((_) {
                                              setDialogState(() {});
                                            });
                                          },
                                          onClear: () {
                                            setState(() {
                                              selectedDayRange = null;
                                              dayRangeStr = null;
                                            });
                                            setDialogState(() {});
                                          },
                                        ),
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
                                    actionsAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.pop();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: AppColors().red,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (selectedDayRange == null ||
                                              _timeRanges.isEmpty) {
                                            showCustomSnackBar(
                                              context: context,
                                              message: "Select Days and Shifts",
                                              backgroundColor: AppColors().red,
                                            );
                                            return;
                                          }
                                          final msg = await JobController()
                                              .repostJob(
                                                widget.jobDetails.copyWith(
                                                  days: dayRangeStr,
                                                  shifts: _timeRanges,
                                                ),
                                              );
                                          if (msg == true) {
                                            context.pop();
                                            showCustomSnackBar(
                                              context: context,
                                              message:
                                                  "Job reposted Successfully",
                                              backgroundColor:
                                                  AppColors().primaryColor,
                                            );
                                          } else {
                                            showCustomSnackBar(
                                              context: context,
                                              message:
                                                  "Failed to repost the Job",
                                              backgroundColor: AppColors().red,
                                            );
                                          }
                                        },
                                        child: Text(
                                          "Repost",
                                          style: TextStyle(
                                            color: AppColors().primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        text: "Repost this Job",
                        textColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        backgroundColor: Colors.red,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Delete"),
                                content: Text(
                                  "Are you sure you want to delete this job?",
                                ),
                                actionsAlignment: MainAxisAlignment.spaceAround,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _onDeleteJob(context),
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
                        text: "Delete this Job",
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDeleteJob(BuildContext context) async {
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
    } else {
      showCustomSnackBar(
        context: context,
        message: "Failed to delete job",
        backgroundColor: Colors.red,
      );
    }
  }
}
