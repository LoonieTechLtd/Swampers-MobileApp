// Test file to validate shift start functionality
// Run this in your app to test if shift start should work today

import 'package:flutter/material.dart';
import 'package:swamper_solution/controllers/shift_controller.dart';

void testShiftStartToday() {
  final shiftController = ShiftController();

  // Test with different date formats that might be used in your app
  final testDateRanges = [
    "20/07/2025 - 25/07/2025", // DD/MM/YYYY format
    "07/20/2025 - 07/25/2025", // MM/DD/YYYY format
    "2025/07/20 - 2025/07/25", // YYYY/MM/DD format
    "20/7/2025 - 25/7/2025", // DD/M/YYYY format
    "7/20/2025 - 7/25/2025", // M/DD/YYYY format
  ];

  debugPrint(
    "=== TESTING SHIFT START FOR TODAY (${DateTime.now().toIso8601String().substring(0, 10)}) ===",
  );

  for (final dateRange in testDateRanges) {
    debugPrint("\n--- Testing date range: '$dateRange' ---");
    final canStart = shiftController.canStartShiftToday(dateRange);
    debugPrint("Result: ${canStart ? '✅ CAN START' : '❌ CANNOT START'}");
  }

  // Test edge cases
  debugPrint("\n--- Testing edge cases ---");

  // Empty date range
  debugPrint("Testing empty date range:");
  final canStartEmpty = shiftController.canStartShiftToday("");
  debugPrint("Result: ${canStartEmpty ? '✅ CAN START' : '❌ CANNOT START'}");

  // Invalid format
  debugPrint("Testing invalid format:");
  final canStartInvalid = shiftController.canStartShiftToday("invalid-format");
  debugPrint("Result: ${canStartInvalid ? '✅ CAN START' : '❌ CANNOT START'}");

  // Current hour check
  final now = DateTime.now();
  debugPrint("Current hour: ${now.hour}");
  if (now.hour >= 23) {
    debugPrint(
      "⚠️ WARNING: Current hour is ${now.hour}, which is past 11 PM. Shifts cannot be started after 11 PM.",
    );
  }
}
