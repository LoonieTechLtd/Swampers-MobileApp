import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';

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

  Future<bool> reauthenticateWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.currentUser!.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint("Failed to reauthenticate with Google: $e");
      return false;
    }
  }

  Future<bool> reauthenticateUser(String password) async {
    try {
      final user = auth.currentUser;
      if (user == null || user.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint("Failed to reauthenticate user: $e");
      return false;
    }
  }

  String? getUserAuthProvider() {
    final user = auth.currentUser;
    if (user == null || user.providerData.isEmpty) return null;

    return user.providerData.first.providerId;
  }

  Future<bool> deleteAccount(
    BuildContext context,
    WidgetRef ref, [
    String? password,
  ]) async {
    try {
      final provider = getUserAuthProvider();
      bool reauthenticated = false;

      // Re-authenticate based on provider
      if (provider == 'google.com') {
        reauthenticated = await reauthenticateWithGoogle();
      } else if (provider == 'password' && password != null) {
        reauthenticated = await reauthenticateUser(password);
      } else {
        debugPrint("Unsupported authentication provider: $provider");
        return false;
      }

      if (!reauthenticated) {
        debugPrint("Reauthentication failed");
        return false;
      }

      // Clear providers
      ref.invalidate(individualProvider);
      ref.invalidate(companyProvider);
      ref.invalidate(getCompanyJobProvider);
      ref.invalidate(getJobProvider);
      ref.invalidate(getUserApplicationsProvider);
      ref.invalidate(getCompanyStats);
      ref.invalidate(getIndividualStats);

      final user = auth.currentUser;
      if (user == null) {
        return false;
      } else {
        // Delete user data from Firestore
        await firestore.collection("profiles").doc(user.uid).delete();

        // Delete the user account
        await user.delete();

        if (context.mounted) {
          context.go("/");
        }
        return true;
      }
    } catch (e) {
      debugPrint("Failed to delete user account: $e");
      return false;
    }
  }
}
