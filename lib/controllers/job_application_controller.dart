import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/services/notificiation_services.dart';

class JobApplicationController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // Method to apply the job
  Future<bool> applyForJob(
    JobApplicationModel newApplication,
    String applicationId,
  ) async {
    try {
      firestore
          .collection("jobApplication")
          .doc(applicationId)
          .set(newApplication.toMap());
      await firestore
          .collection("jobs")
          .doc(newApplication.jobDetails.jobId)
          .update({
            "appliedUsers": FieldValue.arrayUnion([newApplication.applicantId]),
          });

      NotificiationServices.showNotification(
        title: "Job Application Submitted",
        body:
            "Please wait until your job application is approved. It might take a while",
      );
      return true;
    } on FirebaseException catch (e) {
      debugPrint("Error while applying to the job: $e");
      return false;
    }
  }

  // Method to upload PDF file to firebase storage
  Future<String?> uploadResumeToFirebase(File file, String fileName) async {
    try {
      // Check file size (5MB = 5 * 1024 * 1024 bytes)
      const int maxSizeInBytes = 5 * 1024 * 1024; // 5MB
      final int fileSizeInBytes = await file.length();

      if (fileSizeInBytes > maxSizeInBytes) {
        debugPrint(
          "File size exceeds 5MB limit. Current size: ${(fileSizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB",
        );
        return null;
      }

      // Optional: Check if file is PDF
      if (!fileName.toLowerCase().endsWith('.pdf')) {
        debugPrint("File must be a PDF");
        return null;
      }

      final ref = storage
          .ref()
          .child("resume")
          .child(
            auth.currentUser!.uid +
                DateTime.now().millisecondsSinceEpoch.toString() +
                fileName,
          );

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint("Error uploading resume: $e");
      return null;
    }
  }

  // Method to delete job Application
  Future<bool> deleteJobApplication(JobApplicationModel jobApplication) async {
    try {
      // 1. Delete the job application document
      await firestore
          .collection("jobApplication")
          .doc(jobApplication.applicationId)
          .delete();

      // 2. Remove the applicant's UID from the 'appliedUsers' array in the job document
      await firestore
          .collection("jobs")
          .doc(jobApplication.jobDetails.jobId) // Assuming jobDetails has jobId
          .update({
            "appliedUsers": FieldValue.arrayRemove([
              jobApplication.applicantId,
            ]),
          });

      // 3. Delete the associated resume file from storage (existing logic)
      String resumePath = jobApplication.resume;
      if (resumePath.startsWith("http")) {
        final uri = Uri.parse(resumePath);
        final pathParam =
            uri.pathSegments.contains('o')
                ? uri.pathSegments[uri.pathSegments.indexOf('o') + 1]
                : null;
        if (pathParam != null) {
          resumePath = Uri.decodeFull(pathParam);
        } else {
          // fallback: try to extract path from the URL
          final match = RegExp(r"/o/(.+)\\?").firstMatch(resumePath);
          if (match != null) {
            resumePath = Uri.decodeFull(match.group(1)!);
          } else {
            // fallback to just deleting by filename
            resumePath = jobApplication.resume.split('/').last;
          }
        }
      }
      await storage.ref().child(resumePath).delete();

      return true;
    } on FirebaseException catch (e) {
      debugPrint("Failed to delete job application or update job: $e");
      return false;
    } catch (e) {
      debugPrint("An unexpected error occurred: $e");
      return false;
    }
  }

  Future<List<IndividualModel>> fetchAppliedUsers(JobModel job) async {
    List<IndividualModel> appliedUsers = [];
    try {
      if (job.appliedUsers!.isEmpty) {
        debugPrint("No applied users for this job.");
        return appliedUsers; // Return an empty list if no users have applied
      }

      if (job.appliedUsers!.length > 10) {
        debugPrint(
          "Warning: More than 10 applied users. Consider batching queries for better performance and to avoid Firestore 'whereIn' limitations.",
        );
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore
              .collection(
                "profiles",
              )
              .where(FieldPath.documentId, whereIn: job.appliedUsers)
              .get();

      for (var doc in snapshot.docs) {
        try {
          appliedUsers.add(IndividualModel.fromMap(doc.data()));
        } catch (e) {
          debugPrint("Error parsing individual user document: ${doc.id} - $e");
        }
      }
    } on FirebaseException catch (e) {
      debugPrint("Firebase error fetching applied users: $e");
    } catch (e) {
      debugPrint(
        "An unexpected error occurred while fetching applied users: $e",
      );
    }
    return appliedUsers;
  }



  // Method to get User's application
  Stream<List<JobApplicationModel>> getUserApplications(String uid) {
    try {
      return firestore
          .collection("jobApplication")
          .where("applicantId", isEqualTo: uid)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => JobApplicationModel.fromMap(doc.data()))
                    .toList(),
          );
    } catch (e) {
      debugPrint("Error getting user jobs: $e");
      return Stream.value([]);
    }
  }
}
