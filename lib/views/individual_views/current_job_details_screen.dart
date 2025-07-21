import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/controllers/shift_controller.dart';

class CurrentJobDetailsScreen extends ConsumerStatefulWidget {
  final JobApplicationModel jobApplicationData;
  final IndividualModel userData;
  final DateTime? selectedDate;

  const CurrentJobDetailsScreen({
    super.key,
    required this.jobApplicationData,
    required this.userData,
    this.selectedDate,
  });

  @override
  ConsumerState<CurrentJobDetailsScreen> createState() =>
      _CurrentJobDetailsScreenState();
}

class _CurrentJobDetailsScreenState
    extends ConsumerState<CurrentJobDetailsScreen>
    with WidgetsBindingObserver {
  bool _isShiftStarted = false;
  bool _isShiftCompleted = false;
  bool _isLoading = false;
  String? _shiftId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkShiftStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh shift state when app is resumed
      _checkShiftStatus();
    }
  }

  @override
  void didUpdateWidget(CurrentJobDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh shift state when widget updates (e.g., when navigating back)
    _checkShiftStatus();
  }

  Future<void> _checkShiftStatus() async {
    final uid = widget.jobApplicationData.applicantId;
    final jobId = widget.jobApplicationData.jobDetails.jobId;
    final shiftController = ShiftController();

    // Use selected date or default to today
    final dateToCheck = widget.selectedDate ?? DateTime.now();

    try {
      // Use the new method that checks for specific date and job
      final shiftStatus = await shiftController.getShiftStatusForJobAndDate(
        jobId,
        uid,
        dateToCheck,
      );

      if (shiftStatus != null && mounted) {
        setState(() {
          if (shiftStatus['exists'] == true) {
            _shiftId = shiftStatus['shiftId'];
            _isShiftStarted = shiftStatus['isStarted'] ?? false;
            _isShiftCompleted = shiftStatus['isCompleted'] ?? false;
          } else {
            _shiftId = null;
            _isShiftStarted = false;
            _isShiftCompleted = false;
          }
        });
      }
    } catch (e) {
      debugPrint("Error checking shift completion: $e");
    }
  }

  bool _isCurrentDateValidForJob() {
    final shiftController = ShiftController();
    final now = DateTime.now();
    final selectedDate = widget.selectedDate ?? now;

    debugPrint("UI: Checking if selected date is valid for job");
    debugPrint(
      "UI: Job days range: '${widget.jobApplicationData.jobDetails.days}'",
    );
    debugPrint(
      "UI: Selected date: ${selectedDate.toIso8601String().substring(0, 10)}",
    );
    debugPrint("UI: Current date: ${now.toIso8601String().substring(0, 10)}");

    // Use the test method to check if we can start shift today
    if (widget.selectedDate == null) {
      // If no date selected, we're viewing today - use the test method
      debugPrint(
        "UI: No specific date selected, checking if can start shift today",
      );
      final canStartToday = shiftController.canStartShiftToday(
        widget.jobApplicationData.jobDetails.days,
      );
      debugPrint("UI: Can start shift today: $canStartToday");
      return canStartToday;
    }

    // Check if within job period
    final isWithinJobPeriod = shiftController.isCurrentDateValidForJob(
      widget.jobApplicationData.jobDetails.days,
    );

    // CRITICAL: Only allow shift operations on the current day
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final isToday = targetDate.isAtSameMomentAs(today);

    // Additional check: Ensure it's not too late in the day to start a shift (only for today)
    final currentHour = now.hour;
    final isTooLate =
        isToday &&
        currentHour >= 24; // Changed from 23 to 24 to allow 11 PM starts

    debugPrint(
      "UI: Date validation - Within job period: $isWithinJobPeriod, Is today: $isToday, Current hour: $currentHour, Too late: $isTooLate",
    );

    return isWithinJobPeriod && isToday && !isTooLate;
  }

  Color _getDateIndicatorColor() {
    final now = DateTime.now();
    final selectedDate = widget.selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (targetDate.isAtSameMomentAs(today)) {
      return Colors.green; // Today
    } else if (targetDate.isBefore(today)) {
      return Colors.grey; // Past
    } else {
      return Colors.orange; // Future
    }
  }

  IconData _getDateIndicatorIcon() {
    final now = DateTime.now();
    final selectedDate = widget.selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (targetDate.isAtSameMomentAs(today)) {
      return Icons.today; // Today
    } else if (targetDate.isBefore(today)) {
      return Icons.history; // Past
    } else {
      return Icons.schedule; // Future
    }
  }

  String _getDateIndicatorText() {
    final now = DateTime.now();
    final selectedDate = widget.selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final dateStr =
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

    if (targetDate.isAtSameMomentAs(today)) {
      return "Today ($dateStr)";
    } else if (targetDate.isBefore(today)) {
      return "Past Date ($dateStr)";
    } else {
      return "Future Date ($dateStr)";
    }
  }

  Future<void> _handleShiftButton(WidgetRef ref) async {
    if (_isLoading) return; // Prevent multiple simultaneous calls

    setState(() {
      _isLoading = true;
    });

    final shiftController = ref.read(shiftControllerProvider);
    final jobId = widget.jobApplicationData.jobDetails.jobId;
    final uid = widget.jobApplicationData.applicantId;
    final selectedShift = widget.jobApplicationData.selectedShift;

    try {
      // CRITICAL: Prevent any action if shift is already completed
      if (_isShiftCompleted) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Shift already completed for today. Cannot start a new shift.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // STRICT DATE VALIDATION: Only current day allowed
      if (!_isCurrentDateValidForJob()) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          final now = DateTime.now();
          final selectedDate = widget.selectedDate ?? now;
          final today = DateTime(now.year, now.month, now.day);
          final targetDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );

          String message;
          if (!targetDate.isAtSameMomentAs(today)) {
            if (targetDate.isBefore(today)) {
              message =
                  'Cannot start shift: You cannot start shifts for past dates.';
            } else {
              message =
                  'Cannot start shift: You can only start shifts on the current day.';
            }
          } else if (now.hour >= 23) {
            message =
                'Cannot start shift: Too late in the day. Shifts must be started before 11 PM.';
          } else {
            message =
                'Cannot start shift: Selected date is not within the job period.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      await _checkShiftStatus();

      if (_isShiftCompleted) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shift was already completed. Refreshed status.'),
              backgroundColor: Colors.blue,
            ),
          );
        }
        return;
      }

      if (!_isShiftStarted) {
        // START SHIFT
        debugPrint("Attempting to start shift for job: $jobId");
        final shiftId = await shiftController.onStartShift(
          jobId,
          uid,
          shift: selectedShift,
          jobDaysRange:
              widget.jobApplicationData.jobDetails.days, // Pass job date range
        );

        if (mounted) {
          setState(() {
            if (shiftId != null &&
                !shiftId.startsWith("DATE_") &&
                !shiftId.startsWith("NOT_") &&
                !shiftId.startsWith("TOO_")) {
              _isShiftStarted = true;
              _shiftId = shiftId;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Shift started successfully! Your location has been recorded.',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              String errorMessage;
              Color backgroundColor = Colors.red;

              switch (shiftId) {
                case "DATE_OUT_OF_RANGE":
                  errorMessage =
                      'Cannot start shift: Current date is not within the job period.';
                  backgroundColor = Colors.orange;
                  break;
                case "NOT_TODAY":
                case "NOT_CURRENT_DAY":
                  errorMessage =
                      'You can only start shifts for today. Cannot start shifts for past or future dates.';
                  backgroundColor = Colors.red;
                  break;
                case "TOO_LATE":
                  errorMessage =
                      'Cannot start shift: Too late in the day. Shifts must be started before 11 PM.';
                  backgroundColor = Colors.orange;
                  break;
                default:
                  errorMessage =
                      'Failed to start shift. Please check your location services and try again.';
                  break;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: backgroundColor,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
            _isLoading = false;
          });
        }
      } else if (!_isShiftCompleted &&
          _shiftId != null &&
          _shiftId!.isNotEmpty) {
        // END SHIFT
        debugPrint("Attempting to end shift: $_shiftId");
        final result = await shiftController.onEndShift(_shiftId!, uid);

        if (mounted) {
          setState(() {
            if (result) {
              _isShiftCompleted = true;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Shift ended successfully! Your end location has been recorded.',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Failed to end shift. It may already be completed. Please try again.',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
              // Refresh status in case shift was already ended
              _checkShiftStatus();
            }
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        debugPrint("Unexpected shift state - no action taken");
      }
    } catch (e) {
      debugPrint("Error in _handleShiftButton: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
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
            itemCount: widget.jobApplicationData.jobDetails.images.length,
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
                    imageUrl:
                        widget.jobApplicationData.jobDetails.images[index],
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
        if (widget.jobApplicationData.jobDetails.images.length > 1)
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
                    widget.jobApplicationData.jobDetails.images.length,
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

      print("Debug: Final hour: $hour, minute: $minute");
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Debug: Exception in _parseTime: $e");
      return null;
    }
  }

  String _calculateDurationHours(String shift) {
    try {
      final parts = shift.split(" To ");

      if (parts.length != 2) {
        return shift;
      }
      final startTimeStr = parts[0].trim();
      final endTimeStr = parts[1].trim();

      final startTime = _parseTime(startTimeStr);
      final endTime = _parseTime(endTimeStr);

      if (startTime == null || endTime == null) {
        return shift;
      }

      int durationMinutes =
          endTime.hour * 60 +
          endTime.minute -
          (startTime.hour * 60 + startTime.minute);

      if (durationMinutes < 0) {
        durationMinutes += 24 * 60;
      }

      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;

      if (minutes == 0) {
        return "${hours}h";
      } else {
        return "${hours}h ${minutes}m";
      }
    } catch (e) {
      return shift;
    }
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
                  widget.jobApplicationData.jobDetails.role,
                  style: CustomTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "\$${widget.jobApplicationData.jobDetails.hourlyIncome}",
                      style: CustomTextStyles.h3.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "/hr",
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
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
                  widget.jobApplicationData.jobDetails.location,
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
            widget.jobApplicationData.jobDetails.description,
            style: CustomTextStyles.bodyText.copyWith(
              height: 1.5,
              color: Colors.grey.shade700,
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
                    // Date indicator
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getDateIndicatorColor(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getDateIndicatorIcon(),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getDateIndicatorText(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildJobHeader(),
                          const SizedBox(height: 16),
                          // shift details card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: AppColors().primaryColor,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Duration",
                                      style: CustomTextStyles.h4.copyWith(
                                        color: AppColors().white,
                                      ),
                                    ),
                                    Text(
                                      "${_calculateDurationHours(widget.jobApplicationData.selectedShift)}/ Day",
                                      style: CustomTextStyles.h6.copyWith(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                VerticalDivider(indent: 10, endIndent: 10),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Shift",
                                      style: CustomTextStyles.h4.copyWith(
                                        color: AppColors().white,
                                      ),
                                    ),
                                    Text(
                                      widget.jobApplicationData.selectedShift,
                                      style: CustomTextStyles.h6.copyWith(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDescriptionCard(),
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
          child:
              _isShiftCompleted
                  ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Shift completed for today",
                          style: CustomTextStyles.h5.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                  : !_isCurrentDateValidForJob()
                  ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Cannot start upcomming shift",
                          style: CustomTextStyles.bodyText.copyWith(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                  : Consumer(
                    builder: (context, ref, _) {
                      String buttonText;
                      Color buttonColor;
                      bool isEnabled = true;

                      final now = DateTime.now();
                      final selectedDate = widget.selectedDate ?? now;
                      final today = DateTime(now.year, now.month, now.day);
                      final targetDate = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                      );
                      final isToday = targetDate.isAtSameMomentAs(today);

                      if (_isShiftCompleted) {
                        buttonText = "Shift Completed ✓";
                        buttonColor = Colors.green;
                        isEnabled = false;
                      } else if (_isShiftStarted) {
                        if (isToday) {
                          buttonText = "End Shift";
                          buttonColor = Colors.red;
                        } else {
                          buttonText =
                              "Shift in Progress (${selectedDate.day}/${selectedDate.month})";
                          buttonColor = Colors.orange;
                          isEnabled = false;
                        }
                      } else {
                        if (isToday) {
                          buttonText = "Start Today's Shift";
                          buttonColor = AppColors().primaryColor;
                        } else if (targetDate.isBefore(today)) {
                          buttonText = "Past Date - Cannot Start";
                          buttonColor = Colors.grey;
                          isEnabled = false;
                        } else {
                          buttonText = "Future Date - Cannot Start";
                          buttonColor = Colors.grey;
                          isEnabled = false;
                        }
                      }

                      return CustomButton(
                        backgroundColor: buttonColor,
                        onPressed: () {
                          if (isEnabled && !_isShiftCompleted && !_isLoading) {
                            _handleShiftButton(ref);
                          }
                        },
                        text: buttonText,
                        textColor: AppColors().white,
                        isLoading: _isLoading,
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
