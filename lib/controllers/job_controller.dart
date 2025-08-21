import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/core/services/notificiation_services.dart';

class JobController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> postJob(JobModel newJob, String jobId) async {
    try {
      await firestore.collection("jobs").doc(jobId).set(newJob.toMap());

      NotificationServices.showNotification(
        title: "Job Posted",
        body:
            "Please wait until your job is approved.\n this will take some time.",
      );
      return null;
    } catch (e) {
      debugPrint("Error while posting newJob: ${e.toString()}");
      return e.toString();
    }
  }

  // fetch all the available jobs
  Stream<List<JobModel>> getJobs() {
    try {
      return firestore
          .collection("jobs")
          .where("jobStatus", isEqualTo: "Approved")
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return JobModel.fromMap(data);
            }).toList();
          });
    } catch (e) {
      debugPrint("Error while fetching jobs: ${e.toString()}");
      return Stream.value([]);
    }
  }

  // get those job posted by respected company
  Stream<List<JobModel>> getCompanyJobs(String companyId) {
    try {
      return firestore
          .collection("jobs")
          .where("companyId", isEqualTo: companyId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return JobModel.fromMap(data);
            }).toList();
          });
    } catch (e) {
      debugPrint("Error while fetching jobs: ${e.toString()}");
      return Stream.value([]);
    }
  }

  // Update the job details
  Future<bool> updateJob(JobModel updatedJob, String jobId) async {
    try {
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .update(updatedJob.toMap());
      return true;
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }

  // Delete the job
  Future<bool> deleteJob(String jobId, BuildContext context) async {
    try {
      context.pop();
      firestore.collection("jobs").doc(jobId).delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // save or unsave job
  Future<void> saveJob(String jobId) async {
    try {
      final userId = auth.currentUser!.uid.toString();
      final docRef = firestore
          .collection("savedJobs")
          .doc(userId)
          .collection("jobs")
          .doc(jobId);
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({"savedAt": DateTime.now.toString(), "jobId": jobId});
      }
    } catch (e) {
      debugPrint("Failed to save job: ${e.toString()}");
    }
  }

  // to check if the job is saved
  Stream<bool> isJobSaved(String jobId) {
    final userId = auth.currentUser!.uid;
    return firestore
        .collection('savedJobs')
        .doc(userId)
        .collection('jobs')
        .doc(jobId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  //  get all the saved jobs
  Stream<List<JobModel>> getSavedJobs() async* {
    try {
      final userId = auth.currentUser!.uid;
      final savedJobsStream =
          firestore
              .collection('savedJobs')
              .doc(userId)
              .collection('jobs')
              .snapshots();

      await for (final snapshot in savedJobsStream) {
        final jobIds = snapshot.docs.map((doc) => doc.id).toList();

        if (jobIds.isEmpty) {
          yield [];
          continue;
        }
        final jobsSnapshot =
            await firestore
                .collection('jobs')
                .where('jobId', whereIn: jobIds)
                .get();

        final jobs =
            jobsSnapshot.docs
                .map((doc) => JobModel.fromMap(doc.data()))
                .toList();

        yield jobs;
      }
    } catch (e) {
      debugPrint('Error getting saved jobs: ${e.toString()}');
      yield [];
    }
  }

  // upload site images
  Future<List<String>> uploadImages(List<XFile> images) async {
    List<String> downloadUrls = [];
    try {
      for (var image in images) {
        final file = File(image.path);
        if (!file.existsSync()) {
          debugPrint('File does not exist: \\${image.path}');
          continue;
        }
        final ref = FirebaseStorage.instance.ref().child(
          'jobImages/[200m${DateTime.now().millisecondsSinceEpoch}_${image.name}[201m',
        );
        try {
          await ref.putFile(file);
          final url = await ref.getDownloadURL();
          downloadUrls.add(url);
          debugPrint('Uploaded image: \\${image.name}, url: \\$url');
        } catch (e) {
          debugPrint(
            'Error uploading image \\${image.name}: \\${e.toString()}',
          );
        }
      }
      if (downloadUrls.length != images.length) {
        debugPrint(
          'Some images failed to upload. Uploaded: \\${downloadUrls.length}, Selected: \\${images.length}',
        );
      }
      return downloadUrls;
    } catch (e) {
      debugPrint('Error uploading images: \\${e.toString()}');
      return [];
    }
  }

  Future<bool> repostJob(JobModel job, String jobId) async {
    try {
      await firestore.collection("jobs").doc(jobId).set(job.toMap());
      return true;
    } catch (e) {
      debugPrint("Failed to repost the job: $e");
      return false;
    }
  }

  bool searchJob(JobModel jobs, String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    return jobs.role.toLowerCase().contains(lowerKeyword) ||
        jobs.location.toLowerCase().contains(lowerKeyword);
  }

  // Utility method to parse time strings (e.g., "9:00 AM" -> TimeOfDay)
  TimeOfDay? parseTime(String timeStr) {
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

  // Calculate duration hours from shift string (e.g., "9:00 AM To 5:00 PM" -> "8h")
  String calculateDurationHours(String shift) {
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

  // Get color indicator based on selected date
  Color getDateIndicatorColor(DateTime? selectedDate) {
    final now = DateTime.now();
    final dateToCheck = selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      dateToCheck.year,
      dateToCheck.month,
      dateToCheck.day,
    );

    if (targetDate.isAtSameMomentAs(today)) {
      return Colors.green; // Today
    } else if (targetDate.isBefore(today)) {
      return Colors.grey; // Past
    } else {
      return Colors.orange; // Future
    }
  }

  // Get icon indicator based on selected date
  IconData getDateIndicatorIcon(DateTime? selectedDate) {
    final now = DateTime.now();
    final dateToCheck = selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      dateToCheck.year,
      dateToCheck.month,
      dateToCheck.day,
    );

    if (targetDate.isAtSameMomentAs(today)) {
      return Icons.today; // Today
    } else if (targetDate.isBefore(today)) {
      return Icons.history; // Past
    } else {
      return Icons.schedule; // Future
    }
  }

  // Get text indicator based on selected date
  String getDateIndicatorText(DateTime? selectedDate) {
    final now = DateTime.now();
    final dateToCheck = selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      dateToCheck.year,
      dateToCheck.month,
      dateToCheck.day,
    );

    final dateStr =
        "${dateToCheck.day}/${dateToCheck.month}/${dateToCheck.year}";

    if (targetDate.isAtSameMomentAs(today)) {
      return "Today ($dateStr)";
    } else if (targetDate.isBefore(today)) {
      return "Past Date ($dateStr)";
    } else {
      return "Future Date ($dateStr)";
    }
  }

  // Get shift unavailable message based on date and completion status
  String getShiftUnavailableMessage(
    DateTime? selectedDate,
    bool isShiftCompleted,
  ) {
    final now = DateTime.now();
    final dateToCheck = selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      dateToCheck.year,
      dateToCheck.month,
      dateToCheck.day,
    );

    if (targetDate.isBefore(today)) {
      // For past dates, if we reach here, shift was not completed
      return "Cannot start shift for past dates";
    } else if (targetDate.isAfter(today)) {
      return "Cannot start upcoming shift";
    } else {
      // This is today but other conditions failed
      return "Cannot start shift today";
    }
  }

  // Get completed message text based on selected date
  String getCompletedMessageText(DateTime? selectedDate) {
    final now = DateTime.now();
    final dateToCheck = selectedDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      dateToCheck.year,
      dateToCheck.month,
      dateToCheck.day,
    );

    if (targetDate.isAtSameMomentAs(today)) {
      return "Shift completed for today";
    } else if (targetDate.isBefore(today)) {
      return "Shift completed";
    } else {
      return "Shift completed"; // This shouldn't happen for future dates
    }
  }
}
