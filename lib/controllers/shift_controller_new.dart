import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:swamper_solution/models/shift_model.dart';
import 'package:swamper_solution/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class ShiftController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> getCurrentLocation() async {
    try {
      Position? position = await LocationService.getCurrentPosition();
      if (position != null) {
        return LocationService.formatLatLong(position);
      }
      return null;
    } catch (e) {
      debugPrint("Error getting location: $e");
      return null;
    }
  }

  Future<String?> onStartShift(
    String jobId,
    String uid, {
    String? shift,
    String? jobDaysRange, // Add job days range parameter
  }) async {
    try {
      debugPrint("Starting shift for jobId: $jobId, uid: $uid");
      debugPrint("Job days range: $jobDaysRange");

      // CRITICAL: Validate that today is within the job's scheduled date range
      if (jobDaysRange != null && !isCurrentDateValidForJob(jobDaysRange)) {
        debugPrint(
          "Cannot start shift: Current date is not within job's scheduled period",
        );
        return null;
      }

      // STRICT VALIDATION: Ensure we're starting shift only on current day
      final now = DateTime.now();
      final todayStr = now.toIso8601String().substring(0, 10); // yyyy-MM-dd
      final currentHour = now.hour;

      debugPrint("Current date: $todayStr");
      debugPrint("Current hour: $currentHour");

      // Additional validation: Don't allow starting shifts too late in the day
      // Note: Temporarily allowing shifts until midnight for testing
      if (currentHour >= 24) {
        // Changed from 23 to 24 to allow 11 PM starts
        debugPrint("Cannot start shift: Too late in the day");
        return null;
      }

      // Check if a shift already exists for today
      final existingShiftQuery =
          await firestore
              .collection("shifts")
              .where('jobId', isEqualTo: jobId)
              .where('uid', isEqualTo: uid)
              .where('shiftDate', isEqualTo: todayStr)
              .get();

      if (existingShiftQuery.docs.isNotEmpty) {
        final existingShift = ShiftModel.fromMap(
          existingShiftQuery.docs.first.data(),
        );
        if (existingShift.endTime != null) {
          debugPrint("Shift already completed for today");
          return null; // Shift already completed
        } else {
          debugPrint("Shift already in progress for today");
          return existingShift.shiftId; // Return existing shift ID
        }
      }

      String? currentLocation = await getCurrentLocation();
      if (currentLocation == null) {
        debugPrint("Could not get current location");
        return null;
      }

      final shiftId = randomAlphaNumeric(20);
      final startTime = now.toIso8601String();

      final shiftData = ShiftModel(
        shiftId: shiftId,
        uid: uid,
        jobId: jobId,
        startedTime: startTime,
        latLong: currentLocation,
        shiftDate: todayStr, // Store the date separately for easy querying
        isVerified: false
      );

      await firestore.collection("shifts").doc(shiftId).set(shiftData.toMap());

      debugPrint("Shift started successfully with ID: $shiftId");
      return shiftId;
    } catch (e) {
      debugPrint("Error starting shift: $e");
      return null;
    }
  }

  Future<bool> onEndShift(String shiftId, String uid) async {
    try {
      debugPrint("Ending shift with ID: $shiftId");

      String? endLocation = await getCurrentLocation();
      if (endLocation == null) {
        debugPrint("Could not get current location for shift end");
        return false;
      }

      final endTime = DateTime.now().toIso8601String();

      // Use transaction to ensure atomicity
      await firestore.runTransaction((transaction) async {
        final shiftRef = firestore.collection("shifts").doc(shiftId);
        final shiftSnapshot = await transaction.get(shiftRef);

        if (!shiftSnapshot.exists) {
          throw Exception("Shift not found");
        }

        final shiftData = shiftSnapshot.data()!;

        // Verify this shift belongs to the current user
        if (shiftData['uid'] != uid) {
          throw Exception("Unauthorized: Shift belongs to different user");
        }

        // Check if shift is already ended
        if (shiftData['endTime'] != null) {
          throw Exception("Shift already ended");
        }

        // Update shift with end time and location
        transaction.update(shiftRef, {
          'endTime': endTime,
          'endLatLong': endLocation,
        });
      });

      debugPrint("Shift ended successfully");
      return true;
    } catch (e) {
      debugPrint("Error ending shift: $e");
      return false;
    }
  }

  /// Check if the current date is valid for starting a job
  bool isCurrentDateValidForJob(String jobDaysRange) {
    try {
      debugPrint("Validating job date range: '$jobDaysRange'");

      if (jobDaysRange.isEmpty) {
        debugPrint("Job days range is empty");
        return false;
      }

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      debugPrint(
        "Today's date: ${todayDate.toIso8601String().substring(0, 10)}",
      );

      // Parse date range - support both " - " and " to " formats
      List<String> dateRangeParts;
      if (jobDaysRange.contains(' - ')) {
        dateRangeParts = jobDaysRange.split(' - ');
      } else if (jobDaysRange.contains(' to ')) {
        dateRangeParts = jobDaysRange.split(' to ');
      } else {
        debugPrint(
          "Invalid date range format. Expected 'startDate - endDate' or 'startDate to endDate', got: '$jobDaysRange'",
        );
        return false;
      }

      if (dateRangeParts.length != 2) {
        debugPrint(
          "Invalid date range format. Expected 'startDate - endDate' or 'startDate to endDate', got: '$jobDaysRange'",
        );
        return false;
      }

      final startDateParts = dateRangeParts[0].trim().split('/');
      final endDateParts = dateRangeParts[1].trim().split('/');

      if (startDateParts.length != 3 || endDateParts.length != 3) {
        debugPrint(
          "Invalid date format in range. Start parts: $startDateParts, End parts: $endDateParts",
        );
        return false;
      }

      final startDate = DateTime(
        int.parse(startDateParts[2]), // year
        int.parse(startDateParts[1]), // month
        int.parse(startDateParts[0]), // day
      );

      final endDate = DateTime(
        int.parse(endDateParts[2]), // year
        int.parse(endDateParts[1]), // month
        int.parse(endDateParts[0]), // day
      );

      debugPrint(
        "Job start date: ${startDate.toIso8601String().substring(0, 10)}",
      );
      debugPrint("Job end date: ${endDate.toIso8601String().substring(0, 10)}");

      // STRICT CHECK: Only allow if today is exactly within the job date range
      bool isWithinRange =
          todayDate.isAtSameMomentAs(startDate) ||
          todayDate.isAtSameMomentAs(endDate) ||
          (todayDate.isAfter(startDate) && todayDate.isBefore(endDate));

      debugPrint("Is today within job date range: $isWithinRange");
      return isWithinRange;
    } catch (e) {
      debugPrint("Error validating current date for job: $e");
      return false;
    }
  }

  /// Get all shifts for a specific job and user
  Stream<List<ShiftModel>> getShiftsForJob(String jobId, String uid) {
    return firestore
        .collection("shifts")
        .where('jobId', isEqualTo: jobId)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ShiftModel.fromMap(doc.data());
          }).toList();
        });
  }

  /// Get shift status string for a specific date (upcoming, in_progress, completed)
  Future<String> getShiftStatusStringForDate(
    String jobId,
    String uid,
    String date,
  ) async {
    try {
      final shiftQuery =
          await firestore
              .collection("shifts")
              .where('jobId', isEqualTo: jobId)
              .where('uid', isEqualTo: uid)
              .where('shiftDate', isEqualTo: date)
              .get();

      if (shiftQuery.docs.isEmpty) {
        // No shift exists for this date
        final now = DateTime.now();
        final targetDate = DateTime.parse("${date}T00:00:00");

        if (targetDate.isBefore(DateTime(now.year, now.month, now.day))) {
          return 'past'; // Past date with no shift
        } else if (targetDate.isAfter(DateTime(now.year, now.month, now.day))) {
          return 'upcoming'; // Future date
        } else {
          return 'available'; // Today, can start shift
        }
      }

      final shift = ShiftModel.fromMap(shiftQuery.docs.first.data());

      if (shift.isCompleted) {
        return 'completed';
      } else if (shift.isActive) {
        return 'in_progress';
      } else {
        return 'available'; // Shift exists but not started
      }
    } catch (e) {
      debugPrint("Error getting shift status for date $date: $e");
      return 'error';
    }
  }

  /// Get today's shift status for a job
  Future<Map<String, dynamic>?> getTodayShiftStatus(
    String jobId,
    String uid,
  ) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);

      final shiftQuery =
          await firestore
              .collection("shifts")
              .where('jobId', isEqualTo: jobId)
              .where('uid', isEqualTo: uid)
              .where('shiftDate', isEqualTo: today)
              .get();

      if (shiftQuery.docs.isEmpty) {
        // No shift exists for today
        return {
          'exists': false,
          'shiftId': null,
          'isStarted': false,
          'isCompleted': false,
        };
      }

      final shift = ShiftModel.fromMap(shiftQuery.docs.first.data());

      return {
        'exists': true,
        'shiftId': shift.shiftId,
        'isStarted': shift.isActive || shift.isCompleted,
        'isCompleted': shift.isCompleted,
      };
    } catch (e) {
      debugPrint("Error getting today's shift status: $e");
      return null;
    }
  }

  /// Get shift status for a specific date and job
  Future<Map<String, dynamic>?> getShiftStatusForJobAndDate(
    String jobId,
    String uid,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().substring(0, 10);

      final shiftQuery =
          await firestore
              .collection("shifts")
              .where('jobId', isEqualTo: jobId)
              .where('uid', isEqualTo: uid)
              .where('shiftDate', isEqualTo: dateStr)
              .get();

      if (shiftQuery.docs.isEmpty) {
        // No shift exists for this date
        return {
          'exists': false,
          'shiftId': null,
          'isStarted': false,
          'isCompleted': false,
          'canStart': _canStartShiftOnDate(date),
        };
      }

      final shift = ShiftModel.fromMap(shiftQuery.docs.first.data());

      return {
        'exists': true,
        'shiftId': shift.shiftId,
        'isStarted': shift.isActive || shift.isCompleted,
        'isCompleted': shift.isCompleted,
        'canStart': false, // Can't start if shift already exists
      };
    } catch (e) {
      final dateStr = date.toIso8601String().substring(0, 10);
      debugPrint("Error getting shift status for date $dateStr: $e");
      return null;
    }
  }

  /// Check if a shift can be started on a specific date
  bool _canStartShiftOnDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    // Only allow starting shifts on the current day
    return targetDate.isAtSameMomentAs(today) &&
        now.hour < 24; // Changed from 23 to 24
  }

  /// Get shifts for a specific date range
  Future<List<ShiftModel>> getShiftsForDateRange(
    String uid,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateStr = startDate.toIso8601String().substring(0, 10);
      final endDateStr = endDate.toIso8601String().substring(0, 10);

      final query =
          await firestore
              .collection("shifts")
              .where('uid', isEqualTo: uid)
              .where("shiftDate", isGreaterThanOrEqualTo: startDateStr)
              .where("shiftDate", isLessThanOrEqualTo: endDateStr)
              .orderBy("shiftDate", descending: true)
              .get();

      return query.docs.map((doc) {
        return ShiftModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      debugPrint("Error getting shifts for date range: $e");
      return [];
    }
  }

  /// Prevent any historical shift manipulation
  Future<bool> canModifyShift(String shiftId, String uid) async {
    try {
      final shiftDoc = await firestore.collection("shifts").doc(shiftId).get();

      if (!shiftDoc.exists) return false;

      final shiftData = shiftDoc.data()!;
      final shiftDate = shiftData['shiftDate'] as String?;

      if (shiftDate == null) return false;

      final today = DateTime.now();
      final shiftDateTime = DateTime.parse(shiftDate);

      // Only allow modifications for today's shifts
      return shiftDateTime.year == today.year &&
          shiftDateTime.month == today.month &&
          shiftDateTime.day == today.day;
    } catch (e) {
      debugPrint("Error checking shift modification permission: $e");
      return false;
    }
  }

  /// Clean up any invalid or orphaned shift records
  Future<void> cleanupInvalidShifts(String uid) async {
    try {
      final query =
          await firestore
              .collection("shifts")
              .where('uid', isEqualTo: uid)
              .get();

      final batch = firestore.batch();
      int deletionCount = 0;

      for (final doc in query.docs) {
        final data = doc.data();
        final shiftDate = data['shiftDate'] as String?;
        final startedTime = data['startedTime'] as String?;

        // Remove shifts with invalid data
        if (shiftDate == null || startedTime == null) {
          batch.delete(doc.reference);
          deletionCount++;
          continue;
        }

        // Remove shifts that are too old (optional - adjust as needed)
        final shiftDateTime = DateTime.parse(shiftDate);
        final now = DateTime.now();
        final daysDifference = now.difference(shiftDateTime).inDays;

        if (daysDifference > 90) {
          // Keep shifts for 90 days
          batch.delete(doc.reference);
          deletionCount++;
        }
      }

      if (deletionCount > 0) {
        await batch.commit();
        debugPrint(
          "Cleaned up $deletionCount invalid/old shifts for user: $uid",
        );
      }
    } catch (e) {
      debugPrint("Error cleaning up shifts: $e");
    }
  }

  /// Test method to check if shift can be started today for debugging
  bool canStartShiftToday(String jobDaysRange) {
    debugPrint("=== TESTING SHIFT START VALIDATION ===");
    debugPrint(
      "Current date: ${DateTime.now().toIso8601String().substring(0, 10)}",
    );
    debugPrint("Current hour: ${DateTime.now().hour}");
    debugPrint("Job days range: '$jobDaysRange'");

    // Check if current time allows shift start
    final currentHour = DateTime.now().hour;
    if (currentHour >= 24) {
      // Changed from 23 to 24
      debugPrint("❌ Cannot start: Too late in the day (hour: $currentHour)");
      return false;
    }

    // Check if current date is within job range
    final isWithinJobPeriod = isCurrentDateValidForJob(jobDaysRange);
    if (!isWithinJobPeriod) {
      debugPrint("❌ Cannot start: Current date not within job period");
      return false;
    }

    debugPrint("✅ Can start shift today!");
    return true;
  }
}
