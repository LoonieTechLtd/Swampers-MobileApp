import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/models/company_stats_model.dart';
import 'package:swamper_solution/models/individual_stats_model.dart';

class StatsController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // creating a seperate collection to store user stats
  Future<void> createUserStatsCollection(
    IndividualStatsModel userStats,
    String uid,
  ) async {
    try {
      await firestore.collection("stats").doc(uid).set(userStats.toMap());
    } on FirebaseException catch (e) {
      debugPrint("Error wile creating stats collection: ${e.toString()}");
    }
  }

  // creating a seperate collection to store company stats
  Future<void> createCompanyStatsCollection(
    CompanyStatsModel comapnyStats,
    String uid,
  ) async {
    try {
      await firestore.collection("stats").doc(uid).set(comapnyStats.toMap());
    } on FirebaseException catch (e) {
      debugPrint("Error wile creating stats collection: ${e.toString()}");
    }
  }

  Future<IndividualStatsModel?> loadUserStats() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await firestore
              .collection("stats")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

      if (doc.exists) {
        return IndividualStatsModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Unable to load user stats data: ${e.toString()}");
      return null;
    }
  }

  Future<CompanyStatsModel?> loadCompanyStats() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await firestore
              .collection("stats")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

      if (doc.exists) {
        return CompanyStatsModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Unable to load company stats data: ${e.toString()}");
      return null;
    }
  }

  Future<bool> updateCompanyStats(
    int additionalHired,
    int additionalJobs,
  ) async {
    try {
      final docRef = firestore
          .collection("stats")
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data()!;
        int currentHired =
            (data["totalHired"] is double)
                ? (data["totalHired"] as double).toInt()
                : (data["totalHired"] ?? 0) as int;
        int currentJobs =
            (data["totalJobs"] is double)
                ? (data["totalJobs"] as double).toInt()
                : (data["totalJobs"] ?? 0) as int;

        await docRef.update({
          "totalHired": currentHired + additionalHired,
          "totalJobs": currentJobs + additionalJobs,
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Failed to update company stats: $e");
      return false;
    }
  }

  Future<bool> updateIndividualStats(
    double updatedHours,
    int updatedTotalJobs,
  ) async {
    try {
      final docRef = firestore
          .collection("stats")
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data()!;
        int currentJobs = (data["totalJobs"] ?? 0).toInt();
        double currentHours = (data['totalHours'] ?? 0.0).toDouble();

        await docRef.update({
          "totalHours": currentHours + updatedHours,
          "totalJobs": currentJobs + updatedTotalJobs,
        });
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Failed to update individual stats: $e");
      return false;
    }
  }
}
