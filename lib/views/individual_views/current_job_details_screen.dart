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

  String _getShiftUnavailableMessage() {
    final now = DateTime.now();
    final selectedDate = widget.selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (targetDate.isBefore(today)) {
      return "Cannot start shift for past dates";
    } else if (targetDate.isAfter(today)) {
      return "Cannot start upcoming shift";
    } else {
      // This is today but other conditions failed
      return "Cannot start shift today";
    }
  }

  Future<void> _handleShiftButton(WidgetRef ref) async {
    if (_isLoading) return;

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
        Container(
          height: 300,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          child: PageView.builder(
            controller: pageController,
            itemCount: widget.jobApplicationData.jobDetails.images.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            widget.jobApplicationData.jobDetails.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder:
                            (context, url) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[200]!,
                                    Colors.grey[300]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[200]!,
                                    Colors.grey[300]!,
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.jobApplicationData.jobDetails.images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, page, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.jobApplicationData.jobDetails.images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: page == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              page == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
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

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors().primaryColor,
                      AppColors().primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors().primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.work_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.jobApplicationData.jobDetails.role,
                      style: CustomTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.jobApplicationData.jobDetails.location,
                            style: CustomTextStyles.bodyText.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.attach_money_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    Text(
                      "${widget.jobApplicationData.jobDetails.hourlyIncome}",
                      style: CustomTextStyles.h4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "/hr",
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.purple.shade50.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Job Description",
                style: CustomTextStyles.title.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              widget.jobApplicationData.jobDetails.description,
              style: CustomTextStyles.bodyText.copyWith(
                height: 1.6,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
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
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black87,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildImageCarousel(pageController, currentPage),
                      // Date indicator
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getDateIndicatorColor(),
                              _getDateIndicatorColor().withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _getDateIndicatorColor().withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getDateIndicatorIcon(),
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getDateIndicatorText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildJobHeader(),
                            const SizedBox(height: 20),
                            // shift details card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors().primaryColor,
                                    AppColors().primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors().primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 130,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.schedule_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Duration",
                                            style: CustomTextStyles.h4.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${_calculateDurationHours(widget.jobApplicationData.selectedShift)}/Day",
                                            style: CustomTextStyles.h6.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 130,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.access_time_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Shift",
                                            style: CustomTextStyles.h4.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget
                                                .jobApplicationData
                                                .selectedShift,
                                            style: CustomTextStyles.h6.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDescriptionCard(),
                            const SizedBox(
                              height: 100,
                            ), // Extra space for floating button
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ), // End of Column
        ), // End of Container body
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(bottom: 16),
          child:
              _isShiftCompleted
                  ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade50, Colors.green.shade100],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Shift completed for today",
                          style: CustomTextStyles.h5.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                  : !_isCurrentDateValidForJob()
                  ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade50, Colors.orange.shade100],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getShiftUnavailableMessage(),
                          style: CustomTextStyles.bodyText.copyWith(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: buttonColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CustomButton(
                          backgroundColor: buttonColor,
                          onPressed: () {
                            if (isEnabled &&
                                !_isShiftCompleted &&
                                !_isLoading) {
                              _handleShiftButton(ref);
                            }
                          },
                          text: buttonText,
                          textColor: AppColors().white,
                          isLoading: _isLoading,
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
