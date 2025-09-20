import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:swamper_solution/controllers/stats_controller.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/models/company_stats_model.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/individual_stats_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/routes/app_route_config.dart';

class AuthServices {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> userExists(String uid) async {
    try {
      final userDoc = await firestore.collection("profiles").doc(uid).get();
      if (!userDoc.exists) {
        return false;
      }
      return true;
    } catch (e) {
      throw Exception("Error checking if user exists");
    }
  }

  // Method to create user profile with phone number validation using Firestore transaction
  Future<String> createUserProfileWithPhoneValidation({
    required String uid,
    required Map<String, dynamic> profileData,
    required String phoneNumber,
  }) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      return await firestore.runTransaction<String>((transaction) async {
        // Check for existing phone numbers within the transaction
        final phoneQuery =
            await firestore
                .collection("profiles")
                .where("contactNo", isEqualTo: phoneNumber)
                .get();

        final normalizedPhoneQuery =
            await firestore
                .collection("profiles")
                .where("contactNo", isEqualTo: normalizedPhone)
                .get();

        if (phoneQuery.docs.isNotEmpty ||
            normalizedPhoneQuery.docs.isNotEmpty) {
          throw Exception(
            "Phone number is already registered with another account",
          );
        }

        // Additional manual check for phone number variations
        final allProfiles = await firestore.collection("profiles").get();
        for (var doc in allProfiles.docs) {
          final data = doc.data();
          final existingPhone = data['contactNo'] as String?;
          if (existingPhone != null) {
            final existingNormalizedPhone = existingPhone.replaceAll(
              RegExp(r'[^\d]'),
              '',
            );
            if (existingNormalizedPhone == normalizedPhone &&
                existingNormalizedPhone.isNotEmpty &&
                existingNormalizedPhone.length >= 10) {
              throw Exception(
                "Phone number is already registered with another account",
              );
            }
          }
        }

        // If no duplicates found, create the profile
        final userDocRef = firestore.collection("profiles").doc(uid);
        transaction.set(userDocRef, profileData);

        return "Success";
      });
    } catch (e) {
      debugPrint("Error creating user profile: $e");
      return e.toString();
    }
  }

  Future<bool> sendEmailVerificationLink(String email) async {
    try {
      final user = auth.currentUser;
      if (user != null && user.email == email) {
        await user.sendEmailVerification();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> completeAppleUserProfile({
    required String uid,
    required String email,
    required String phone,
    required String address,
    required String type,
    String? firstName,
    String? lastName,
    String? interestedWork,
    String? companyName,
  }) async {
    try {
      // Normalize phone number at the beginning
      final normalizedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

      if (type == "Individual") {
        if (firstName == null || lastName == null) {
          return "First name and last name are required for individual profiles";
        }

        final IndividualModel newUser = IndividualModel(
          uid: uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          address: address,
          role: "Individual",
          contactNo: normalizedPhone, // Use normalized phone
          profilePic:
              "https://i.pinimg.com/736x/87/14/55/8714556a52021ba3a55c8e7a3547d28c.jpg",
          kycVerified: "notSubmitted",
          interestedWork: interestedWork!,
          createdAt: DateTime.now().toString(),
          oneTimeResume: "",
        );

        // Use transaction-based profile creation to prevent duplicate phone numbers
        final profileCreationResult =
            await createUserProfileWithPhoneValidation(
              uid: uid,
              profileData: newUser.toMap(),
              phoneNumber: phone,
            );

        if (profileCreationResult != "Success") {
          return profileCreationResult;
        }

        final IndividualStatsModel stats = IndividualStatsModel(
          uid: uid,
          totalHours: 0,
          totalJobs: 0,
        );

        await StatsController().createUserStatsCollection(stats, uid);
      } else if (type == "Company") {
        if (companyName == null) {
          return "Company name is required for company profiles";
        }

        final CompanyModel newCompany = CompanyModel(
          uid: uid,
          companyName: companyName,
          email: email,
          role: "Company",
          contactNo: normalizedPhone, // Use normalized phone
          profilePic:
              "https://i.pinimg.com/736x/87/14/55/8714556a52021ba3a55c8e7a3547d28c.jpg",
          address: address,
          createdAt: DateTime.now().toString(),
          isSuspended: false,
        );

        // Use transaction-based profile creation to prevent duplicate phone numbers
        final profileCreationResult =
            await createUserProfileWithPhoneValidation(
              uid: uid,
              profileData: newCompany.toMap(),
              phoneNumber: phone,
            );

        if (profileCreationResult != "Success") {
          return profileCreationResult;
        }

        final CompanyStatsModel companyStats = CompanyStatsModel(
          uid: uid,
          totalJobs: 0,
          totalHired: 0,
        );

        await StatsController().createCompanyStatsCollection(companyStats, uid);
      }

      return "Success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> completeGoogleUserProfile({
    required String uid,
    required String email,
    required String phone,
    required String address,
    required String type,
    String? firstName,
    String? lastName,
    String? interestedWork,
    String? companyName,
  }) async {
    try {
      // Normalize phone number at the beginning
      final normalizedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

      if (type == "Individual") {
        if (firstName == null || lastName == null) {
          return "First name and last name are required for individual profiles";
        }

        final IndividualModel newUser = IndividualModel(
          uid: uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          address: address,
          role: "Individual",
          contactNo: normalizedPhone, // Use normalized phone
          profilePic:
              "https://i.pinimg.com/736x/87/14/55/8714556a52021ba3a55c8e7a3547d28c.jpg",
          kycVerified: "notSubmitted",
          interestedWork: interestedWork!,
          createdAt: DateTime.now().toString(),
          oneTimeResume: "",
        );

        // Use transaction-based profile creation to prevent duplicate phone numbers
        final profileCreationResult =
            await createUserProfileWithPhoneValidation(
              uid: uid,
              profileData: newUser.toMap(),
              phoneNumber: phone,
            );

        if (profileCreationResult != "Success") {
          return profileCreationResult;
        }

        final IndividualStatsModel stats = IndividualStatsModel(
          uid: uid,
          totalHours: 0,
          totalJobs: 0,
        );

        await StatsController().createUserStatsCollection(stats, uid);
      } else if (type == "Company") {
        if (companyName == null) {
          return "Company name is required for company profiles";
        }

        final CompanyModel newCompany = CompanyModel(
          uid: uid,
          companyName: companyName,
          email: email,
          role: "Company",
          contactNo: normalizedPhone, // Use normalized phone
          profilePic:
              "https://i.pinimg.com/736x/87/14/55/8714556a52021ba3a55c8e7a3547d28c.jpg",
          address: address,
          createdAt: DateTime.now().toString(),
          isSuspended: false,
        );

        // Use transaction-based profile creation to prevent duplicate phone numbers
        final profileCreationResult =
            await createUserProfileWithPhoneValidation(
              uid: uid,
              profileData: newCompany.toMap(),
              phoneNumber: phone,
            );

        if (profileCreationResult != "Success") {
          return profileCreationResult;
        }

        final CompanyStatsModel companyStats = CompanyStatsModel(
          uid: uid,
          totalJobs: 0,
          totalHired: 0,
        );

        await StatsController().createCompanyStatsCollection(companyStats, uid);
      }

      return "Success";
    } catch (e) {
      return e.toString();
    }
  }

  // google login method
  Future<dynamic> loginWithGoogle([WidgetRef? ref]) async {
    try {
      final googleSignIn = GoogleSignIn();

      // Force google sign Out
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return "Google sign in cancelled";

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );

      if (ref != null) {
        ref.invalidate(companyProvider);
        ref.invalidate(individualProvider);
        ref.invalidate(getCompanyJobProvider);
        ref.invalidate(getJobProvider);
        ref.invalidate(getIndividualStats);
      }

      try {
        final exists = await userExists(userCredential.user!.uid);

        if (!exists) {
          return {
            "status": "new_user",
            "uid": userCredential.user!.uid,
            "email": userCredential.user!.email,
          };
        }

        final userDoc =
            await firestore
                .collection("profiles")
                .doc(userCredential.user!.uid)
                .get();
        final role = userDoc.get("role");

        if (role == "Individual" || role == "Company") {
          return role.toString();
        } else {
          // Delete the account from Firebase Auth and sign out
          await userCredential.user!.delete();
          await auth.signOut();
          return "Invalid user role. Account removed.";
        }
      } catch (e) {
        // Delete the account from Firebase Auth and sign out
        try {
          await userCredential.user!.delete();
        } catch (deleteError) {
          debugPrint("Error deleting user: $deleteError");
        }
        await auth.signOut();
        return "Error checking user profile. Account removed.";
      }
    } catch (e) {
      return "Failed to sign in with Google: $e";
    }
  }

  //-------------------------------------------------------------------------------------------------------------

  //register function for a normal user
  Future<String?> registerUser(
    String email,
    String password,
    String firstName,
    String lastName,
    String contactNo,
    String address,
    String profilePic,
    String interestedWork,
  ) async {
    try {
      // Normalize phone number by removing any spaces, dashes, or special characters
      final normalizedContactNo = contactNo.replaceAll(RegExp(r'[^\d]'), '');

      debugPrint(
        "Registering user with phone: $contactNo (normalized: $normalizedContactNo)",
      );

      // First create the user account in Firebase Auth
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification link
      await userCredential.user!.sendEmailVerification();

      // Now check for duplicate phone numbers and create profile using transaction
      final IndividualModel newUser = IndividualModel(
        uid: userCredential.user!.uid.toString(),
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        role: "Individual",
        contactNo: normalizedContactNo, // Store normalized phone number
        profilePic: profilePic,
        kycVerified: "notSubmitted",
        interestedWork: interestedWork,
        createdAt: DateTime.now().toString(),
        oneTimeResume: "",
      );

      final profileCreationResult = await createUserProfileWithPhoneValidation(
        uid: userCredential.user!.uid,
        profileData: newUser.toMap(),
        phoneNumber: contactNo,
      );

      if (profileCreationResult != "Success") {
        // Delete the auth account if profile creation failed
        await userCredential.user!.delete();
        await auth.signOut();
        return profileCreationResult;
      }

      final IndividualStatsModel stats = IndividualStatsModel(
        uid: userCredential.user!.uid,
        totalHours: 0,
        totalJobs: 0,
      );

      await StatsController().createUserStatsCollection(
        stats,
        userCredential.user!.uid,
      );

      debugPrint(
        "User registered successfully with UID: ${userCredential.user!.uid}",
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "FirebaseAuthException during registration: ${e.code} - ${e.message}",
      );
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email is already registered';
        case 'invalid-email':
          return 'Invalid email format';
        case 'weak-password':
          return 'Password should be at least 6 characters';
        default:
          return 'Registration failed. Please try again';
      }
    } catch (e) {
      return 'Registration failed. Please try again';
    }
  }

  //-------------------------------------------------------------------------------------------------------------

  //register function for a company
  Future<String?> registerCompany(
    String email,
    String password,
    String companyName,
    String contactNo,
    String address,
    String profilePic,
  ) async {
    try {
      // Normalize phone number by removing any spaces, dashes, or special characters
      final normalizedContactNo = contactNo.replaceAll(RegExp(r'[^\d]'), '');

      debugPrint(
        "Registering company with phone: $contactNo (normalized: $normalizedContactNo)",
      );

      // First create the user account in Firebase Auth
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification link
      await userCredential.user!.sendEmailVerification();

      // Now check for duplicate phone numbers and create profile using transaction
      final CompanyModel newCompany = CompanyModel(
        uid: userCredential.user!.uid.toString(),
        companyName: companyName,
        email: email,
        role: "Company",
        contactNo: normalizedContactNo, // Store normalized phone number
        profilePic: profilePic,
        address: address,
        createdAt: DateTime.now().toString(),
        isSuspended: false,
      );

      final profileCreationResult = await createUserProfileWithPhoneValidation(
        uid: userCredential.user!.uid,
        profileData: newCompany.toMap(),
        phoneNumber: contactNo,
      );

      if (profileCreationResult != "Success") {
        // Delete the auth account if profile creation failed
        await userCredential.user!.delete();
        await auth.signOut();
        return profileCreationResult;
      }

      final CompanyStatsModel companyStats = CompanyStatsModel(
        uid: userCredential.user!.uid,
        totalJobs: 0,
        totalHired: 0,
      );

      await StatsController().createCompanyStatsCollection(
        companyStats,
        userCredential.user!.uid,
      );

      debugPrint(
        "Company registered successfully with UID: ${userCredential.user!.uid}",
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "FirebaseAuthException during company registration: ${e.code} - ${e.message}",
      );
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email is already registered';
        case 'invalid-email':
          return 'Invalid email format';
        case 'weak-password':
          return 'Password should be at least 6 characters';
        default:
          return 'Registration failed. Please try again';
      }
    } catch (e) {
      debugPrint("Unexpected error during company registration: $e");
      return 'Registration failed. Please try again';
    }
  }

  //-------------------------------------------------------------------------------------------------------------
  // common login method
  Future<String> login(String email, String password, [WidgetRef? ref]) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (await haveEmailInFirestore(email) == false) {
        try {
          await auth.currentUser?.delete();
        } catch (deleteError) {
          debugPrint("Error deleting user: $deleteError");
        }
        return "No user found !";
      }
      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        return 'email-not-verified';
      }

      // Invalidate providers to force reload of user data after login
      if (ref != null) {
        ref.invalidate(companyProvider);
        ref.invalidate(individualProvider);
        ref.invalidate(getCompanyJobProvider);
        ref.invalidate(getJobProvider);
        ref.invalidate(getIndividualStats);
      }

      try {
        // Check if user exists in Firestore
        bool exists = await userExists(userCredential.user!.uid);
        if (!exists) {
          try {
            await userCredential.user!.delete();
          } catch (deleteError) {
            debugPrint("Error deleting user: $deleteError");
          }
          await auth.signOut();
          return 'User profile not found. Account removed.';
        }

        // Get user's role from Firestore
        final userDoc =
            await firestore
                .collection("profiles")
                .doc(userCredential.user!.uid)
                .get();
        final role = userDoc.get("role");

        if (role == "Individual" || role == "Company") {
          return role.toString();
        } else {
          try {
            await userCredential.user!.delete();
          } catch (deleteError) {
            debugPrint("Error deleting user: $deleteError");
          }
          await auth.signOut();
          return 'Invalid user role. Account removed.';
        }
      } catch (e) {
        try {
          await userCredential.user!.delete();
        } catch (deleteError) {
          debugPrint("Error deleting user: $deleteError");
        }
        await auth.signOut();
        return 'Error accessing user profile. Account removed.';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password';
        case 'invalid-email':
          return 'Invalid email format';
        case 'user-disabled':
          return 'This account has been disabled';
        default:
          return 'Login failed: Email or Password is incorrect';
      }
    } catch (e) {
      return 'Login failed. Please try again';
    }
  }

  //-------------------------------------------------------------------------------------------------------------

  // common logout method
  Future<void> logout(BuildContext context, WidgetRef ref) async {
    try {
      ref.invalidate(individualProvider);
      ref.invalidate(companyProvider);
      ref.invalidate(getCompanyJobProvider);
      ref.invalidate(getJobProvider);
      ref.invalidate(getUserApplicationsProvider);
      ref.invalidate(getCompanyStats);
      ref.invalidate(getIndividualStats);

      await auth.signOut();
      await GoogleSignIn().signOut();

      // Clear route cache to prevent stale data
      AppRouteConfig.clearCache();

      // Always redirect to login
      if (context.mounted) {
        context.go("/");
      }
    } catch (e) {
      debugPrint("Failed to logout: $e");
    }
  }

  //-------------------------------------------------------------------------------------------------------------
  // Reset Password method
  Future<bool> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Password reset error: ${e.toString()}");
      return false;
    }
  }

  //-------------------------------------------------------------------------------------------------------------
  // Change Password method
  Future<String> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return "No user signed in";
      }

      // Re-authenticate the user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return "Success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          return 'Current password is incorrect';
        case 'weak-password':
          return 'New password should be at least 6 characters';
        case 'requires-recent-login':
          return 'Please log out and log in again to change password';
        default:
          return 'Failed to change password: ${e.message}';
      }
    } catch (e) {
      return 'Failed to change password. Please try again';
    }
  }

  Future<bool> haveSameNumber(String phoneNo) async {
    try {
      // Normalize phone number by removing any spaces, dashes, or special characters
      final normalizedPhone = phoneNo.replaceAll(RegExp(r'[^\d]'), '');

      debugPrint(
        "Checking phone number: $phoneNo (normalized: $normalizedPhone)",
      );

      // Check with original phone number format
      final res =
          await firestore
              .collection("profiles")
              .where("contactNo", isEqualTo: phoneNo)
              .get();

      debugPrint(
        "Found ${res.docs.length} documents with phone number: $phoneNo",
      );

      if (res.docs.isNotEmpty) {
        return true;
      }

      // Also check with normalized phone number to catch different formats
      if (phoneNo != normalizedPhone) {
        final normalizedRes =
            await firestore
                .collection("profiles")
                .where("contactNo", isEqualTo: normalizedPhone)
                .get();

        debugPrint(
          "Found ${normalizedRes.docs.length} documents with normalized phone number: $normalizedPhone",
        );

        if (normalizedRes.docs.isNotEmpty) {
          return true;
        }
      }

      // Additional comprehensive check: Query all profiles and check manually
      // This ensures we catch any edge cases with different phone formats
      final allProfiles = await firestore.collection("profiles").get();

      for (var doc in allProfiles.docs) {
        final data = doc.data();
        final existingPhone = data['contactNo'] as String?;
        if (existingPhone != null) {
          final existingNormalizedPhone = existingPhone.replaceAll(
            RegExp(r'[^\d]'),
            '',
          );
          if (existingNormalizedPhone == normalizedPhone &&
              existingNormalizedPhone.isNotEmpty &&
              existingNormalizedPhone.length >= 10) {
            debugPrint(
              "Found matching phone number in manual check: $existingPhone (normalized: $existingNormalizedPhone)",
            );
            return true;
          }
        }
      }

      debugPrint("No duplicate phone number found");
      return false;
    } on FirebaseException catch (e) {
      debugPrint(
        "Firestore error while checking phone number: ${e.code} - ${e.message}",
      );

      // Handle specific permission errors
      if (e.code == 'permission-denied') {
        debugPrint(
          "Permission denied - user may not be authenticated or lacks proper permissions",
        );
      }

      // For any Firestore errors, throw the exception to be handled by caller
      throw Exception("Unable to verify phone number uniqueness: ${e.message}");
    } catch (e) {
      debugPrint("Unexpected error checking phone number: $e");
      // For unexpected errors, throw the exception to be handled by caller
      throw Exception("Unable to verify phone number uniqueness: $e");
    }
  }

  Future<List<Map<String, dynamic>>> debugPhoneNumbers() async {
    try {
      final allProfiles = await firestore.collection("profiles").get();

      List<Map<String, dynamic>> phoneData = [];

      for (var doc in allProfiles.docs) {
        final data = doc.data();
        final phone = data['contactNo'] as String?;
        final email = data['email'] as String?;
        final role = data['role'] as String?;

        if (phone != null) {
          phoneData.add({
            'uid': doc.id,
            'email': email,
            'role': role,
            'originalPhone': phone,
            'normalizedPhone': phone.replaceAll(RegExp(r'[^\d]'), ''),
          });
        }
      }

      return phoneData;
    } catch (e) {
      debugPrint("Error getting phone numbers for debugging: $e");
      return [];
    }
  }

  Future<bool> haveEmailInFirestore(String email) async {
    try {
      final res =
          await firestore
              .collection("profiles")
              .where("email", isEqualTo: email)
              .get();
      return res.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking email in firestore: $e");
      return false;
    }
  }

  Future<dynamic> signInWithApple([WidgetRef? ref]) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final UserCredential userCredential = await auth.signInWithCredential(
        oAuthCredential,
      );

      if (ref != null) {
        ref.invalidate(companyProvider);
        ref.invalidate(individualProvider);
        ref.invalidate(getCompanyJobProvider);
        ref.invalidate(getJobProvider);
        ref.invalidate(getIndividualStats);
      }

      try {
        final exists = await userExists(userCredential.user!.uid);

        if (!exists) {
          return {
            "status": "new_user",
            "uid": userCredential.user!.uid,
            "email": userCredential.user!.email,
            "name":
                credential.givenName != null && credential.familyName != null
                    ? "${credential.givenName} ${credential.familyName}"
                    : null,
          };
        }

        final userDoc =
            await firestore
                .collection("profiles")
                .doc(userCredential.user!.uid)
                .get();
        final role = userDoc.get("role");

        if (role == "Individual" || role == "Company") {
          return role.toString();
        } else {
          // Delete the account from Firebase Auth and sign out
          await userCredential.user!.delete();
          await auth.signOut();
          return "Invalid user role. Account removed.";
        }
      } catch (e) {
        // Delete the account from Firebase Auth and sign out
        try {
          await userCredential.user!.delete();
        } catch (deleteError) {
          debugPrint("Error deleting user: $deleteError");
        }
        await auth.signOut();
        return "Error checking user profile. Account removed.";
      }
    } catch (e) {
      return "Failed to sign in with Apple: $e";
    }
  }
}
