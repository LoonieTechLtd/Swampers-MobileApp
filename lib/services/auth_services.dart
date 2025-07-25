import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/controllers/stats_controller.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/models/company_stats_model.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/individual_stats_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/routes/app_route_config.dart';
import 'package:swamper_solution/views/common/signup_screen/individual_form.dart';

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
          contactNo: phone,
          profilePic:
              "https://i.pinimg.com/736x/87/14/55/8714556a52021ba3a55c8e7a3547d28c.jpg",
          kycVerified: "notSubmitted",
          interestedWork: interestedWork!,
          createdAt: DateTime.now().toString(),
        );

        final IndividualStatsModel stats = IndividualStatsModel(
          uid: uid,
          totalHours: 0,
          totalJobs: 0,
          totalEarning: 0,
        );

        await firestore.collection("profiles").doc(uid).set(newUser.toMap());

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
          contactNo: phone,
          profilePic:
              "https://i.pinimg.com/736x/87/14/55/8714556a52021ba3a55c8e7a3547d28c.jpg",
          address: address,
          createdAt: DateTime.now().toString(),
          isSuspended: false,
        );

        final CompanyStatsModel companyStats = CompanyStatsModel(
          uid: uid,
          totalJobs: 0,
          totalHired: 0,
          totalPay: 0,
        );

        await firestore.collection("profiles").doc(uid).set(newCompany.toMap());

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
          await auth.signOut();
          return "Invalid user role";
        }
      } catch (e) {
        await auth.signOut();
        return "Error checking user profile: $e";
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
      sendOtp(email);
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final IndividualModel newUser = IndividualModel(
        uid: userCredential.user!.uid.toString(),
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        role: "Individual",
        contactNo: contactNo,
        profilePic: profilePic,
        kycVerified: "notSubmitted",
        interestedWork: interestedWork,
        createdAt: DateTime.now().toString(),
      );

      final IndividualStatsModel stats = IndividualStatsModel(
        uid: userCredential.user!.uid,
        totalHours: 0,
        totalJobs: 0,
        totalEarning: 0,
      );
      await firestore
          .collection("profiles")
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      StatsController().createUserStatsCollection(
        stats,
        userCredential.user!.uid,
      );

      return "Success";
    } on FirebaseAuthException catch (e) {
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
      sendOtp(email);

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final CompanyModel newCompany = CompanyModel(
        uid: userCredential.user!.uid.toString(),
        companyName: companyName,
        email: email,
        role: "Company",
        contactNo: contactNo,
        profilePic: profilePic,
        address: address,
        createdAt: DateTime.now().toString(),
        isSuspended: false,
      );

      final CompanyStatsModel companyStats = CompanyStatsModel(
        uid: userCredential.user!.uid,
        totalJobs: 0,
        totalHired: 0,
        totalPay: 0,
      );
      await firestore
          .collection("profiles")
          .doc(userCredential.user!.uid)
          .set(newCompany.toMap());

      StatsController().createCompanyStatsCollection(
        companyStats,
        userCredential.user!.uid,
      );

      return "Success";
    } on FirebaseAuthException catch (e) {
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
          await auth.signOut();
          return 'signup'; // Special return value to indicate signup needed
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
          await auth.signOut();
          return 'Invalid user role. Please contact support';
        }
      } catch (e) {
        await auth.signOut();
        return 'Error accessing user profile. Please try again';
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
          return 'Login failed: ${e.message}';
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

  //-------------------------------------------------------------------------------------------------------------
  // Sent a email verification OTP
  Future<bool> sendOtp(String email) async {
    try {
      EmailOTP.sendOTP(email: email);
      return true;
    } catch (e) {
      debugPrint("Error while sending OTP: $e");
      return false;
    }
  }

  bool verifyOtp(String otp, BuildContext context) {
    var res = EmailOTP.verifyOTP(otp: otp);
    if (res) {
      showCustomSnackBar(context: context, message: "OTP verified");
      return true;
    } else {
      showCustomSnackBar(
        context: context,
        message: "Invalid OTP !",
        backgroundColor: AppColors().red,
      );
      return false;
    }
  }
}
