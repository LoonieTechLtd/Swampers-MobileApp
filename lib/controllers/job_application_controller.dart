import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:swamper_solution/models/job_application_model.dart';
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
      await firestore
          .collection("jobApplication")
          .doc(jobApplication.applicationId)
          .delete();
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
    } catch (e) {
      debugPrint("Failed to delete job application: $e");
      return false;
    }
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
