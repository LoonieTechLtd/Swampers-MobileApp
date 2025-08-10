import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/controllers/job_application_controller.dart';
import 'package:swamper_solution/controllers/job_controller.dart';
import 'package:swamper_solution/controllers/job_offers_controller.dart';
import 'package:swamper_solution/controllers/job_template_controller.dart';
import 'package:swamper_solution/controllers/kyc_controller.dart';
import 'package:swamper_solution/controllers/message_controller.dart';
import 'package:swamper_solution/controllers/notification_controller.dart';
import 'package:swamper_solution/controllers/shift_controller.dart';
import 'package:swamper_solution/controllers/stats_controller.dart';
import 'package:swamper_solution/controllers/user_controller.dart';
import 'package:swamper_solution/models/crimers_model.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/models/jobs_template_model.dart';

final FirebaseFirestore firestor = FirebaseFirestore.instance;

final roleProvider = StateProvider<List<bool>>((ref) {
  return [true, false];
});

final criminalProvider = StateProvider<bool>((ref) {
  return false;
});

final crimeListProvider = StateProvider<List<CrimersModel>>((ref) {
  return [];
});

final applicationProvider = StateProvider<List<bool>>((ref) {
  return [true, false];
});
final employmentProvider = StateProvider<List<bool>>((ref) {
  return [true, false];
});

final isPasswordVisible = StateProvider<bool>((ref) {
  return false;
});

final getJobHistoryProvider = StreamProvider((ref) {
  return JobOffersController().getJobHistory();
});

final individualProvider = FutureProvider<IndividualModel?>((ref) async {
  return await UserController().loadIndividualData();
});

final companyProvider = FutureProvider((ref) async {
  return await UserController().loadCompanyData();
});

final getJobProvider = StreamProvider((ref) {
  return JobController().getJobs();
});

final getJobOffersProvider = StreamProvider((ref) {
  return JobOffersController().getJobsOffer();
});

final getCompanyJobProvider = StreamProvider((ref) {
  return JobController().getCompanyJobs(
    FirebaseAuth.instance.currentUser!.uid.toString(),
  );
});

final jobControllerProvider = Provider((ref) => JobController());

final savedJobsProvider = StreamProvider.family<bool, String>((ref, jobId) {
  return ref.watch(jobControllerProvider).isJobSaved(jobId);
});

final getAllSavedJobsProvider = StreamProvider<List<JobModel>>((ref) {
  return ref.watch(jobControllerProvider).getSavedJobs();
});

final getIndividualStats = FutureProvider((ref) async {
  return await StatsController().loadUserStats();
});

final getCompanyStats = FutureProvider((ref) async {
  return await StatsController().loadCompanyStats();
});

final getUserApplicationsProvider = StreamProvider((ref) {
  return JobApplicationController().getUserApplications(
    FirebaseAuth.instance.currentUser!.uid,
  );
});

final getUserMessage = StreamProvider((ref) {
  return MessageController().getUserMessages(
    FirebaseAuth.instance.currentUser!.uid,
  );
});

final getUserNotifications = StreamProvider((ref) {
  return NotificationController().getUserNotification();
});

final kycStatusProvider = FutureProvider((ref) {
  return KycController().haveKycApplication(
    FirebaseAuth.instance.currentUser!.uid,
  );
});

final getKycData = FutureProvider((ref) {
  return KycController().getKycData();
});

final notificationControllerProvider = Provider(
  (ref) => NotificationController(),
);

final jobTemplateProvider = FutureProvider<List<JobsTemplateModel>>((ref) {
  return JobTemplateController().fetchJobTemplates();
});

final appliedUsersProvider = FutureProvider.family<
  List<IndividualModel>,
  JobModel
>((ref, jobModel) async {
  try {
    final users = await JobApplicationController().fetchAppliedUsers(jobModel);
    return users;
  } catch (e) {
    debugPrint("Error fetching applied users for job ${jobModel.jobId}: $e");
    rethrow;
  }
});

final getCurrentJobsProvider =
    StreamProvider.family<List<JobApplicationModel>, DateTime>((
      ref,
      selectedDate,
    ) {
      return JobApplicationController().getCurrentJobs(selectedDate);
    });

final shiftControllerProvider = Provider((ref) => ShiftController());


final todayShiftStatusProvider = FutureProvider.family<
  Map<String, dynamic>?,
  ({String jobId, String uid})
>((ref, params) async {
  final shiftController = ref.read(shiftControllerProvider);
  return await shiftController.getTodayShiftStatus(params.jobId, params.uid);
});

// Provider to get current day's jobs (today only)
final getCurrentDayJobsProvider = StreamProvider<List<JobApplicationModel>>((
  ref,
) {
  final today = DateTime.now();
  return JobApplicationController().getCurrentJobs(today);
});

// Provider to check shift status for a specific job and date
final shiftStatusProvider = FutureProvider.family<
  Map<String, dynamic>?,
  ({String jobId, String uid, DateTime date})
>((ref, params) async {
  final shiftController = ref.read(shiftControllerProvider);
  return await shiftController.getShiftStatusForJobAndDate(
    params.jobId,
    params.uid,
    params.date,
  );
});

// Provider to check if shift is completed for a specific job and date
final isShiftCompletedProvider =
    FutureProvider.family<bool, ({String jobId, String uid, DateTime date})>((
      ref,
      params,
    ) async {
      final shiftStatus = await ref.watch(shiftStatusProvider(params).future);
      return shiftStatus?['isCompleted'] ?? false;
    });

// Provider to check if shift is started for a specific job and date
final isShiftStartedProvider =
    FutureProvider.family<bool, ({String jobId, String uid, DateTime date})>((
      ref,
      params,
    ) async {
      final shiftStatus = await ref.watch(shiftStatusProvider(params).future);
      return shiftStatus?['isStarted'] ?? false;
    });

// Provider to check if the selected date is valid for starting/ending shifts
final isDateValidForShiftProvider =
    Provider.family<bool, ({String jobDaysRange, DateTime? selectedDate})>((
      ref,
      params,
    ) {
      final now = DateTime.now();
      final targetDate = params.selectedDate ?? now;
      final today = DateTime(now.year, now.month, now.day);
      final targetDateOnly = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );

      // Check if date is today
      final isToday = targetDateOnly.isAtSameMomentAs(today);

      // Check if within job period using shift controller
      final shiftController = ShiftController();
      final isWithinJobPeriod = shiftController.isCurrentDateValidForJob(
        params.jobDaysRange,
      );

      // Don't allow shifts if it's too late in the day
      final currentHour = now.hour;
      final isTooLate = isToday && currentHour >= 24;

      return isWithinJobPeriod && isToday && !isTooLate;
    });

// Provider to check if date is in the past
final isPastDateProvider = Provider.family<bool, DateTime?>((
  ref,
  selectedDate,
) {
  if (selectedDate == null) return false;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );

  return targetDate.isBefore(today);
});

// Provider to check if date is in the future
final isFutureDateProvider = Provider.family<bool, DateTime?>((
  ref,
  selectedDate,
) {
  if (selectedDate == null) return false;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );

  return targetDate.isAfter(today);
});

// Provider to get date status (today, past, future)
final dateStatusProvider = Provider.family<String, DateTime?>((
  ref,
  selectedDate,
) {
  if (selectedDate == null) return 'today';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );

  if (targetDate.isAtSameMomentAs(today)) {
    return 'today';
  } else if (targetDate.isBefore(today)) {
    return 'past';
  } else {
    return 'future';
  }
});

// Provider to get shift button text based on current state
final shiftButtonTextProvider = Provider.family<
  String,
  ({String jobId, String uid, DateTime? selectedDate, String jobDaysRange})
>((ref, params) {
  final now = DateTime.now();
  final selectedDate = params.selectedDate ?? now;
  final today = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final isToday = targetDate.isAtSameMomentAs(today);

  // Check if date is valid for shift operations
  final isValidDate = ref.watch(
    isDateValidForShiftProvider((
      jobDaysRange: params.jobDaysRange,
      selectedDate: params.selectedDate,
    )),
  );

  // Get shift status
  final shiftStatusAsync = ref.watch(
    shiftStatusProvider((
      jobId: params.jobId,
      uid: params.uid,
      date: selectedDate,
    )),
  );

  return shiftStatusAsync.when(
    data: (shiftStatus) {
      final isStarted = shiftStatus?['isStarted'] ?? false;
      final isCompleted = shiftStatus?['isCompleted'] ?? false;

      if (isCompleted) {
        return "Shift Completed ✓";
      } else if (isStarted) {
        if (isToday) {
          return "End Shift";
        } else {
          return "Shift in Progress (${selectedDate.day}/${selectedDate.month})";
        }
      } else {
        if (isToday && isValidDate) {
          return "Start Today's Shift";
        } else if (targetDate.isBefore(today)) {
          return "Past Date - Cannot Start";
        } else {
          return "Future Date - Cannot Start";
        }
      }
    },
    loading: () => "Loading...",
    error: (_, __) => "Error - Try Again",
  );
});

// Provider to get shift button color
final shiftButtonColorProvider = Provider.family<
  Color,
  ({String jobId, String uid, DateTime? selectedDate, String jobDaysRange})
>((ref, params) {
  final buttonText = ref.watch(shiftButtonTextProvider(params));

  if (buttonText.contains("Completed")) {
    return Colors.green;
  } else if (buttonText.contains("End Shift")) {
    return Colors.red;
  } else if (buttonText.contains("Progress")) {
    return Colors.orange;
  } else if (buttonText.contains("Start Today")) {
    return AppColors().primaryColor;
  } else {
    return Colors.grey;
  }
});

// Provider to check if shift button should be enabled
final isShiftButtonEnabledProvider = Provider.family<
  bool,
  ({String jobId, String uid, DateTime? selectedDate, String jobDaysRange})
>((ref, params) {
  final now = DateTime.now();
  final selectedDate = params.selectedDate ?? now;
  final today = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final isToday = targetDate.isAtSameMomentAs(today);

  // Get shift status
  final shiftStatusAsync = ref.watch(
    shiftStatusProvider((
      jobId: params.jobId,
      uid: params.uid,
      date: selectedDate,
    )),
  );

  return shiftStatusAsync.when(
    data: (shiftStatus) {
      final isStarted = shiftStatus?['isStarted'] ?? false;
      final isCompleted = shiftStatus?['isCompleted'] ?? false;

      if (isCompleted) {
        return false; // Completed shifts can't be modified
      }

      if (isStarted && !isToday) {
        return false; // Can't end shift on non-today dates
      }

      if (!isStarted && !isToday) {
        return false; // Can't start shift on non-today dates
      }

      // Check if date is valid for shift operations
      final isValidDate = ref.watch(
        isDateValidForShiftProvider((
          jobDaysRange: params.jobDaysRange,
          selectedDate: params.selectedDate,
        )),
      );

      return isValidDate;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});
