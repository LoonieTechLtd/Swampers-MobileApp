import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/controllers/shift_controller.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';

class JobHelperMethods {
  // Time parsing helper method
  static TimeOfDay? parseTime(String timeStr) {
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

  // Calculate duration hours for shift
  static String calculateDurationHours(String shift) {
    try {
      final parts = shift.split(" To ");

      if (parts.length != 2) {
        return shift;
      }
      final startTimeStr = parts[0].trim();
      final endTimeStr = parts[1].trim();

      final startTime = parseTime(startTimeStr);
      final endTime = parseTime(endTimeStr);

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

  // Check shift status for a specific job and date
  static Future<Map<String, dynamic>?> checkShiftStatus({
    required String jobId,
    required String uid,
    required DateTime dateToCheck,
  }) async {
    final shiftController = ShiftController();

    try {
      // Use the new method that checks for specific date and job
      final shiftStatus = await shiftController.getShiftStatusForJobAndDate(
        jobId,
        uid,
        dateToCheck,
      );

      if (shiftStatus != null) {
        if (shiftStatus['exists'] == true) {
          return {
            'shiftId': shiftStatus['shiftId'],
            'isStarted': shiftStatus['isStarted'] ?? false,
            'isCompleted': shiftStatus['isCompleted'] ?? false,
          };
        } else {
          return {'shiftId': null, 'isStarted': false, 'isCompleted': false};
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error checking shift completion: $e");
      return null;
    }
  }

  // Check if current date is valid for job
  static bool isCurrentDateValidForJob({
    required String jobDaysRange,
    DateTime? selectedDate,
  }) {
    final shiftController = ShiftController();
    final now = DateTime.now();
    final targetDate = selectedDate ?? now;

    debugPrint("UI: Checking if selected date is valid for job");
    debugPrint("UI: Job days range: '$jobDaysRange'");
    debugPrint(
      "UI: Selected date: ${targetDate.toIso8601String().substring(0, 10)}",
    );
    debugPrint("UI: Current date: ${now.toIso8601String().substring(0, 10)}");

    // Use the test method to check if we can start shift today
    if (selectedDate == null) {
      // If no date selected, we're viewing today - use the test method
      debugPrint(
        "UI: No specific date selected, checking if can start shift today",
      );
      final canStartToday = shiftController.canStartShiftToday(jobDaysRange);
      debugPrint("UI: Can start shift today: $canStartToday");
      return canStartToday;
    }

    // Check if within job period
    final isWithinJobPeriod = shiftController.isCurrentDateValidForJob(
      jobDaysRange,
    );

    // CRITICAL: Only allow shift operations on the current day
    final today = DateTime(now.year, now.month, now.day);
    final targetDateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final isToday = targetDateOnly.isAtSameMomentAs(today);

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

  // Get date indicator color
  static Color getDateIndicatorColor({DateTime? selectedDate}) {
    final now = DateTime.now();
    final targetDate = selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final selectedDateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    if (selectedDateOnly.isAtSameMomentAs(today)) {
      return Colors.green; // Today
    } else if (selectedDateOnly.isBefore(today)) {
      return Colors.grey; // Past
    } else {
      return Colors.orange; // Future
    }
  }

  // Get date indicator icon
  static IconData getDateIndicatorIcon({DateTime? selectedDate}) {
    final now = DateTime.now();
    final targetDate = selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final selectedDateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    if (selectedDateOnly.isAtSameMomentAs(today)) {
      return Icons.today; // Today
    } else if (selectedDateOnly.isBefore(today)) {
      return Icons.history; // Past
    } else {
      return Icons.schedule; // Future
    }
  }

  // Get date indicator text
  static String getDateIndicatorText({DateTime? selectedDate}) {
    final now = DateTime.now();
    final targetDate = selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final selectedDateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final dateStr = "${targetDate.day}/${targetDate.month}/${targetDate.year}";

    if (selectedDateOnly.isAtSameMomentAs(today)) {
      return "Today ($dateStr)";
    } else if (selectedDateOnly.isBefore(today)) {
      return "Past Date ($dateStr)";
    } else {
      return "Future Date ($dateStr)";
    }
  }

  // Get shift unavailable message
  static String getShiftUnavailableMessage({DateTime? selectedDate}) {
    final now = DateTime.now();
    final targetDate = selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final selectedDateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    if (selectedDateOnly.isBefore(today)) {
      return "Cannot start shift for past dates";
    } else if (selectedDateOnly.isAfter(today)) {
      return "Cannot start upcoming shift";
    } else {
      // This is today but other conditions failed
      return "Cannot start shift today";
    }
  }

  // Handle shift button operations
  static Future<Map<String, dynamic>> handleShiftButton({
    required WidgetRef ref,
    required JobApplicationModel jobApplicationData,
    required DateTime? selectedDate,
    required bool isShiftStarted,
    required bool isShiftCompleted,
    required String? shiftId,
    required BuildContext context,
  }) async {
    final shiftController = ref.read(shiftControllerProvider);
    final jobId = jobApplicationData.jobDetails.jobId;
    final uid = jobApplicationData.applicantId;
    final selectedShift = jobApplicationData.selectedShift;

    Map<String, dynamic> result = {
      'success': false,
      'newShiftStarted': false,
      'newShiftCompleted': false,
      'newShiftId': shiftId,
      'message': '',
      'backgroundColor': Colors.red,
    };

    try {
      // CRITICAL: Prevent any action if shift is already completed
      if (isShiftCompleted) {
        result['message'] =
            'Shift already completed for today. Cannot start a new shift.';
        result['backgroundColor'] = Colors.orange;
        return result;
      }

      // STRICT DATE VALIDATION: Only current day allowed
      if (!isCurrentDateValidForJob(
        jobDaysRange: jobApplicationData.jobDetails.days,
        selectedDate: selectedDate,
      )) {
        final now = DateTime.now();
        final targetDate = selectedDate ?? now;
        final today = DateTime(now.year, now.month, now.day);
        final selectedDateOnly = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
        );

        String message;
        if (!selectedDateOnly.isAtSameMomentAs(today)) {
          if (selectedDateOnly.isBefore(today)) {
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

        result['message'] = message;
        result['backgroundColor'] = Colors.red;
        return result;
      }

      // Check shift status again before proceeding
      final shiftStatus = await checkShiftStatus(
        jobId: jobId,
        uid: uid,
        dateToCheck: selectedDate ?? DateTime.now(),
      );

      if (shiftStatus != null && shiftStatus['isCompleted'] == true) {
        result['message'] = 'Shift was already completed. Refreshed status.';
        result['backgroundColor'] = Colors.blue;
        result['newShiftCompleted'] = true;
        return result;
      }

      if (!isShiftStarted) {
        // START SHIFT
        debugPrint("Attempting to start shift for job: $jobId");
        final newShiftId = await shiftController.onStartShift(
          jobId,
          uid,
          shift: selectedShift,
          jobDaysRange: jobApplicationData.jobDetails.days,
        );

        if (newShiftId != null &&
            !newShiftId.startsWith("DATE_") &&
            !newShiftId.startsWith("NOT_") &&
            !newShiftId.startsWith("TOO_")) {
          result['success'] = true;
          result['newShiftStarted'] = true;
          result['newShiftId'] = newShiftId;
          result['message'] =
              'Shift started successfully! Your location has been recorded.';
          result['backgroundColor'] = Colors.green;
        } else {
          String errorMessage;
          Color backgroundColor = Colors.red;

          switch (newShiftId) {
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

          result['message'] = errorMessage;
          result['backgroundColor'] = backgroundColor;
        }
      } else if (!isShiftCompleted && shiftId != null && shiftId.isNotEmpty) {
        // END SHIFT
        debugPrint("Attempting to end shift: $shiftId");
        final endResult = await shiftController.onEndShift(shiftId, uid);

        if (endResult) {
          result['success'] = true;
          result['newShiftCompleted'] = true;
          result['message'] =
              'Shift ended successfully! Your end location has been recorded.';
          result['backgroundColor'] = Colors.green;
        } else {
          result['message'] =
              'Failed to end shift. It may already be completed. Please try again.';
          result['backgroundColor'] = Colors.red;
        }
      } else {
        debugPrint("Unexpected shift state - no action taken");
        result['message'] =
            'Unexpected shift state. Please refresh and try again.';
      }
    } catch (e) {
      debugPrint("Error in handleShiftButton: $e");
      result['message'] = 'An unexpected error occurred. Please try again.';
      result['backgroundColor'] = Colors.red;
    }

    return result;
  }
}
