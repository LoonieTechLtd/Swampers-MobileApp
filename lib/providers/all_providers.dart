import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';
import 'package:swamper_solution/controllers/job_application_controller.dart';
import 'package:swamper_solution/controllers/job_controller.dart';
import 'package:swamper_solution/controllers/kyc_controller.dart';
import 'package:swamper_solution/controllers/message_controller.dart';
import 'package:swamper_solution/controllers/notification_controller.dart';
import 'package:swamper_solution/controllers/stats_controller.dart';
import 'package:swamper_solution/controllers/user_controller.dart';
import 'package:swamper_solution/models/crimers_model.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_model.dart';

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

final isPasswordVisible = StateProvider<bool>((ref) {
  return false;
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
