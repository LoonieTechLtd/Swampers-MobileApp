import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/descriptionCard.dart';
import 'package:swamper_solution/views/custom_widgets/image_carousel.dart';
import 'package:swamper_solution/views/custom_widgets/job_header.dart';
import 'package:swamper_solution/core/services/helper_methods.dart';

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

    // Use selected date or default to today
    final dateToCheck = widget.selectedDate ?? DateTime.now();

    final shiftStatus = await JobHelperMethods.checkShiftStatus(
      jobId: jobId,
      uid: uid,
      dateToCheck: dateToCheck,
    );

    if (shiftStatus != null && mounted) {
      setState(() {
        _shiftId = shiftStatus['shiftId'];
        _isShiftStarted = shiftStatus['isStarted'] ?? false;
        _isShiftCompleted = shiftStatus['isCompleted'] ?? false;
      });
    }
  }

  bool _isCurrentDateValidForJob() {
    return JobHelperMethods.isCurrentDateValidForJob(
      jobDaysRange: widget.jobApplicationData.jobDetails.days,
      selectedDate: widget.selectedDate,
    );
  }

  Color _getDateIndicatorColor() {
    return JobHelperMethods.getDateIndicatorColor(
      selectedDate: widget.selectedDate,
    );
  }

  IconData _getDateIndicatorIcon() {
    return JobHelperMethods.getDateIndicatorIcon(
      selectedDate: widget.selectedDate,
    );
  }

  String _getDateIndicatorText() {
    return JobHelperMethods.getDateIndicatorText(
      selectedDate: widget.selectedDate,
    );
  }

  String _getShiftUnavailableMessage() {
    return JobHelperMethods.getShiftUnavailableMessage(
      selectedDate: widget.selectedDate,
    );
  }

  Future<void> _handleShiftButton(WidgetRef ref) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await JobHelperMethods.handleShiftButton(
        ref: ref,
        jobApplicationData: widget.jobApplicationData,
        selectedDate: widget.selectedDate,
        isShiftStarted: _isShiftStarted,
        isShiftCompleted: _isShiftCompleted,
        shiftId: _shiftId,
        context: context,
      );

      if (mounted) {
        setState(() {
          if (result['newShiftStarted'] == true) {
            _isShiftStarted = true;
            _shiftId = result['newShiftId'];
          }
          if (result['newShiftCompleted'] == true) {
            _isShiftCompleted = true;
          }
          _isLoading = false;
        });

        // Show the result message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['backgroundColor'],
            duration: Duration(seconds: result['success'] == true ? 3 : 4),
          ),
        );

        // Refresh status if operation failed to ensure consistency
        if (result['success'] != true) {
          _checkShiftStatus();
        }
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
                      buildImageCarousel(
                        pageController,
                        currentPage,
                        widget.jobApplicationData.jobDetails.images,
                      ),
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
                            buildJobHeader(
                              jobDetails: widget.jobApplicationData.jobDetails,
                            ),
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
                                            "${JobHelperMethods.calculateDurationHours(widget.jobApplicationData.selectedShift)}/Day",
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
                            buildDescriptionCard(
                              description:
                                  widget
                                      .jobApplicationData
                                      .jobDetails
                                      .description,
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
        ),
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
