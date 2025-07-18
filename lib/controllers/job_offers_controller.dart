import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_model.dart';

class JobOffersController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  Stream<List<JobModel>> getJobsOffer() {
    try {
      return firestore
          .collection("jobs")
          .where(
            "assignedStaffs",
            arrayContains: {
              'id': auth.currentUser!.uid,
              'email': auth.currentUser!.email,
            },
          )
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return JobModel.fromMap(data);
            }).toList();
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // method works when accept the job
  Future<bool> onJobAccept(IndividualModel userData, JobModel jobData) async {
    try {
      final batch = firestore.batch();

      final historyRef = firestore.collection("jobHistory").doc(userData.uid);
      batch.set(historyRef, {
        "jobId": FieldValue.arrayUnion([jobData.jobId]),
      }, SetOptions(merge: true));

      final querySnap =
          await firestore
              .collection("jobApplications")
              .where("jobDetails.id", isEqualTo: jobData.jobId)
              .get();

      for (final doc in querySnap.docs) {
        batch.update(doc.reference, {"applicationStatus": "Approved"});
      }
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint("Failed to accept the job and create job history: $e");
      return false;
    }
  }

  // list all the job history
  Stream<List<JobModel>> getJobHistory() async* {
    final historyDocStream =
        firestore
            .collection('jobHistory')
            .doc(auth.currentUser!.uid)
            .snapshots();

    await for (final snapshot in historyDocStream) {
      if (!snapshot.exists) {
        yield [];
        continue;
      }

      final ids = List<String>.from(snapshot.data()?['jobId'] ?? []);
      if (ids.isEmpty) {
        yield [];
        continue;
      }

      final chunks = <List<String>>[];
      for (var i = 0; i < ids.length; i += 10) {
        chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
      }

      final futures = chunks.map((chunk) {
        return firestore
            .collection('jobs')
            .where('jobId', whereIn: chunk)
            .get();
      });

      final querySnaps = await Future.wait(futures);
      final allDocs = querySnaps.expand((qs) => qs.docs);

      final jobs = allDocs
          .map((doc) => JobModel.fromMap(doc.data()))
          .toList(growable: false);

      yield jobs;
    }
  }

  Future<bool> onJobOfferRejected(
    JobModel jobData,
    IndividualModel userData,
  ) async {
    try {
      final batch = firestore.batch();

      // Add to job history
      final historyRef = firestore.collection("jobHistory").doc(userData.uid);
      batch.set(historyRef, {
        "jobId": FieldValue.arrayUnion([jobData.jobId]),
      }, SetOptions(merge: true));

      // Update job applications status to "Rejected"
      final querySnap =
          await firestore
              .collection("jobApplications")
              .where("jobDetails.id", isEqualTo: jobData.jobId)
              .where("applicantId", isEqualTo: userData.uid) // Add user filter
              .get();

      for (final doc in querySnap.docs) {
        batch.update(doc.reference, {"applicationStatus": "Rejected"});
      }

      // Remove the user from assignedStaffs array in the job document
      final jobRef = firestore.collection("jobs").doc(jobData.jobId);
      batch.update(jobRef, {
        "assignedStaffs": FieldValue.arrayRemove([
          {'id': userData.uid, 'email': userData.email},
        ]),
      });

      await batch.commit();
      debugPrint("Job offer rejected successfully for user ${userData.uid}");
      return true;
    } catch (e) {
      debugPrint("Failed to reject job offer: $e");
      return false;
    }
  }
}
