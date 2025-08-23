import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swamper_solution/models/individual_kyc_model.dart';
import 'package:swamper_solution/models/individual_model.dart';

class KycController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // to apply kyc
  Future<bool> applyKyc(
    IndividualKycModel newKyc,
    IndividualModel individualData,
  ) async {
    try {
      await firestore
          .collection("kycApplications")
          .doc(newKyc.userInfo.uid)
          .set(newKyc.toMap());
      updateKycStatus(individualData);

      return true;
    } catch (e) {
      debugPrint("Failed to upload KYC details: $e");
      return false;
    }
  }

  // method to upload KYC doc images
  Future<String?> uploadDoc(String uid, XFile image, String docType) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('kycDocs')
          .child('$uid/$docType.jpg');
      await storageRef.putData(await image.readAsBytes());
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Failed to upload Image: $e');
      return null;
    }
  }

  // method to upload KYC documents (PDF, DOC, etc.)
  Future<String?> uploadDocumentFile(
    String uid,
    File file,
    String docType,
    String fileName,
  ) async {
    try {
      // Get file extension
      final extension = fileName.split('.').last.toLowerCase();

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('kycDocs')
          .child('$uid/$docType.$extension');

      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Failed to upload Document: $e');
      return null;
    }
  }

  // get kyc model
  Future<IndividualKycModel?> getKycData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await firestore
              .collection("kycApplications")
              .doc(auth.currentUser!.uid)
              .get();

      if (doc.exists) {
        return IndividualKycModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Unable to load Kyc data: ${e.toString()}");
      return null;
    }
  }

  // change kyc Status
  Future<bool> updateKycStatus(IndividualModel individualData) async {
    try {
      await firestore.collection("profiles").doc(individualData.uid).update({
        "kycVerified": "pending",
      });
      return true;
    } catch (e) {
      debugPrint("Error updating the kyc status");
      return false;
    }
  }

  // update kyc application
  Future<bool> updateKycApplication(IndividualKycModel updatedKyc) async {
    try {
      await firestore
          .collection("kycApplications")
          .doc(auth.currentUser!.uid)
          .update(updatedKyc.toMap());
      await firestore.collection("profiles").doc(auth.currentUser!.uid).update({
        "kycVerified": "pending",
      });
      return true;
    } catch (e) {
      debugPrint("Failed to update kyc $e");
      return false;
    }
  }

  // to check if the kyc application is there
  Future<bool> haveKycApplication(String uid) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection("kycApplications").doc(uid).get();
      if (!doc.exists) {
        return false;
      }
      return true;
    } catch (e) {
      debugPrint("Error while checking kyc status: $e");
      return false;
    }
  }
}
