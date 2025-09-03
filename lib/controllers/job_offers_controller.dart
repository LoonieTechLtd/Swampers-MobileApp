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
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        debugPrint("No current user found - user not authenticated");
        return Stream.value([]);
      }

      debugPrint(
        "Fetching job offers for user: ${currentUser.uid} (${currentUser.email})",
      );

      return firestore.collection("jobs").snapshots().map((snapshot) {
        debugPrint("Fetched ${snapshot.docs.length} jobs from Firestore");

        if (snapshot.docs.isEmpty) {
          debugPrint("No jobs found in Firestore collection");
          return <JobModel>[];
        }

        final jobs =
            snapshot.docs
                .map((doc) {
                  try {
                    final data = doc.data();
                    debugPrint("Processing job document: ${doc.id}");
                    final job = JobModel.fromMap(data);
                    debugPrint(
                      "Job ${job.jobId} has ${job.assignedStaffs.length} assigned staffs",
                    );
                    return job;
                  } catch (e) {
                    debugPrint("Error parsing job document ${doc.id}: $e");
                    return null;
                  }
                })
                .where((job) => job != null)
                .cast<JobModel>()
                .where((job) {
                  try {
                    // Check if the current user is in the assignedStaffs array
                    final assignedStaffs = job.assignedStaffs;
                    if (assignedStaffs.isEmpty) {
                      debugPrint("Job ${job.jobId} has no assigned staffs");
                      return false;
                    }

                    debugPrint("Job ${job.jobId} assigned staffs:");
                    for (var staff in assignedStaffs) {
                      debugPrint(
                        "  - ${staff.id} (${staff.email}) - hasAccepted: ${staff.hasAccepted}",
                      );
                    }

                    final isUserAssigned = assignedStaffs.any((staff) {
                      // staff is AssignedStaff object, not Map
                      final matchesId = staff.id == currentUser.uid;
                      final matchesEmail = staff.email == currentUser.email;

                      return matchesId && matchesEmail;
                    });

                    if (isUserAssigned) {
                      debugPrint(
                        "✓ User ${currentUser.uid} is assigned to job ${job.jobId}",
                      );
                    } else {
                      debugPrint(
                        "✗ User ${currentUser.uid} is NOT assigned to job ${job.jobId}",
                      );
                    }

                    return isUserAssigned;
                  } catch (e) {
                    debugPrint("Error filtering job ${job.jobId}: $e");
                    return false;
                  }
                })
                .toList();

        debugPrint(
          "Found ${jobs.length} job offers for user ${currentUser.uid}",
        );
        return jobs;
      });
    } catch (e) {
      debugPrint("Error fetching job offers: $e");
      return Stream.value([]);
    }
  }

  // method to accept job offer
  Future<bool> onJobAccept(IndividualModel userData, JobModel jobData) async {
    try {
      // First, get the current job document to access assignedStaffs
      DocumentSnapshot jobDoc =
          await firestore.collection("jobs").doc(jobData.jobId).get();

      if (!jobDoc.exists) {
        debugPrint("Job document not found");
        return false;
      }

      // Extract and update assignedStaffs array
      Map<String, dynamic> jobDocData = jobDoc.data() as Map<String, dynamic>;
      List<dynamic> assignedStaffs = List.from(
        jobDocData['assignedStaffs'] ?? [],
      );

      // Find and update the specific user's hasAccepted field
      bool userFoundInAssignedStaffs = false;
      for (int i = 0; i < assignedStaffs.length; i++) {
        if (assignedStaffs[i]['id'] == userData.uid) {
          assignedStaffs[i]['hasAccepted'] = true;
          userFoundInAssignedStaffs = true;
          break;
        }
      }

      if (!userFoundInAssignedStaffs) {
        debugPrint("User not found in assignedStaffs list");
        return false;
      }

      // Create batch for all operations
      final batch = firestore.batch();

      // 1. Update job history
      final historyRef = firestore.collection("jobHistory").doc(userData.uid);
      batch.set(historyRef, {
        "jobId": FieldValue.arrayUnion([jobData.jobId]),
      }, SetOptions(merge: true));

      // 2. Update job document with both appliedUsers and assignedStaffs
      final jobRef = firestore.collection("jobs").doc(jobData.jobId);
      batch.update(jobRef, {
        "appliedUsers": FieldValue.arrayUnion([userData.uid]),
        "assignedStaffs": assignedStaffs,
      });

      // 3. Update job applications status
      final querySnap =
          await firestore
              .collection("jobApplication")
              .where("jobDetails.jobId", isEqualTo: jobData.jobId)
              .get();

      for (final doc in querySnap.docs) {
        batch.update(doc.reference, {"applicationStatus": "Approved"});
      }

      // Commit all changes
      await batch.commit();

      debugPrint("Successfully accepted job and updated all related documents");
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

      final querySnap =
          await firestore
              .collection("jobApplication")
              .where("jobDetails.jobId", isEqualTo: jobData.jobId)
              .where("applicantId", isEqualTo: userData.uid)
              .get();

      for (final doc in querySnap.docs) {
        batch.delete(doc.reference);
      }


      // Remove the user from assignedStaffs array in the job document
      final jobRef = firestore.collection("jobs").doc(jobData.jobId);

      // First get the current job document to find the exact assignedStaff entry
      final jobDoc = await jobRef.get();
      if (jobDoc.exists) {
        final jobData = jobDoc.data() as Map<String, dynamic>;
        final currentAssignedStaffs = List<Map<String, dynamic>>.from(
          jobData['assignedStaffs'] ?? [],
        );

      

        // Remove the matching staff entry
        currentAssignedStaffs.removeWhere(
          (staff) =>
              staff['id'] == userData.uid && staff['email'] == userData.email,
        );

        batch.update(jobRef, {"assignedStaffs": currentAssignedStaffs});
      }

      await batch.commit();
      debugPrint("Job offer rejected successfully for user ${userData.uid}");
      return true;
    } catch (e) {
      debugPrint("Failed to reject job offer: $e");
      return false;
    }
  }

  Future<bool> isJobAccepted(JobModel jobData) async {
    try {
      final uid = auth.currentUser!.uid;
      final doc = await firestore.collection("jobs").doc(jobData.jobId).get();
      final appliedUsers = List<String>.from(doc.data()?["appliedUsers"] ?? []);
      return appliedUsers.contains(uid);
    } catch (e) {
      debugPrint("Error checking status");
      return false;
    }
  }
}
