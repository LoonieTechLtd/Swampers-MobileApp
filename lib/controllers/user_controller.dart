import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/models/individual_model.dart';

class UserController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<IndividualModel?> loadIndividualData() async {
    try {
      final uid = auth.currentUser!.uid.toString();
      DocumentSnapshot<Map<String, dynamic>> doc =
          await firestore.collection("profiles").doc(uid).get();
      if (doc.exists) {
        return IndividualModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Unable to load user data: ${e.toString()}");
      return null;
    }
  }

  Future<CompanyModel?> loadCompanyData() async {
    try {
      final uid = auth.currentUser!.uid.toString();
      DocumentSnapshot<Map<String, dynamic>> doc =
          await firestore.collection("profiles").doc(uid).get();
      if (doc.exists) {
        return CompanyModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Unable to load user data: ${e.toString()}");
      return null;
    }
  }

  // method to update individual profile
  Future<void> updateIndividualProfile(
    IndividualModel updatedIndividualData,
  ) async {
    try {
      await firestore
          .collection("profiles")
          .doc(auth.currentUser!.uid)
          .update(updatedIndividualData.toMap());
    } catch (e) {
      debugPrint("Failed to update profile: ${e.toString()}");
    }
  }

  // method to update profile pic of the individual user
  Future<String?> uploadProfilePic(String uid, XFile image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePic')
          .child('$uid.jpg');
      await storageRef.putData(await image.readAsBytes());
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Failed to upload profile pic: $e');
      return null;
    }
  }

  // method to update company data
  Future<void> updateCompanyProfile(CompanyModel updatedCompanyData) async {
    try {
      firestore
          .collection("profiles")
          .doc(auth.currentUser!.uid)
          .update(updatedCompanyData.toMap());
    } catch (e) {
      debugPrint("Failed to update company profile: ${e.toString()}");
    }
  }

  Future<String?> getOneTimeResumeUrl() async {
    try {
      final String uid = auth.currentUser!.uid.toString();
      DocumentSnapshot<Map<String, dynamic>> doc =
          await firestore.collection("profiles").doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        return data?['oneTimeResume'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint("Failed to get one time resume URL: $e");
      return null;
    }
  }

  Future<XFile?> pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return XFile(result.files.single.path!);
      }
      return null;
    } catch (e) {
      debugPrint("Failed to pick PDF file: $e");
      return null;
    }
  }




  Future<String> addOneTimeResume(XFile resume) async {
    try {
      final String uid = auth.currentUser!.uid.toString();
      final storageRef = storage.ref().child("oneTimeResume/$uid.pdf");
      await storageRef.putData(await resume.readAsBytes());
      final downloadUrl = await storageRef.getDownloadURL();

      await firestore.collection("profiles").doc(uid).update({
        "oneTimeResume": downloadUrl,
      });
      return downloadUrl;
    } catch (e) {
      debugPrint("Failed to upload one time resume: $e");
      return "";
    }
  }


}
