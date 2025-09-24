import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/views/common/email_verification_screen.dart';
import 'package:swamper_solution/views/company_views/admin_contact_screen.dart';
import 'package:swamper_solution/views/company_views/delete_company_account_screen.dart';
import 'package:swamper_solution/views/company_views/edit_job_screen.dart';
import 'package:swamper_solution/views/company_views/job_posting_screen.dart';
import 'package:swamper_solution/views/company_views/jobs_screen.dart';
import 'package:swamper_solution/views/company_views/posted_job_details_screen.dart';
import 'package:swamper_solution/views/individual_views/current_job_details_screen.dart';
import 'package:swamper_solution/views/individual_views/delete_account_screen.dart';
import 'package:swamper_solution/views/individual_views/individual_kyc_application_screen.dart';
import 'package:swamper_solution/views/individual_views/job_details_screen.dart';
import 'package:swamper_solution/views/individual_views/job_offer_screen.dart';
import 'package:swamper_solution/views/individual_views/kyc_review_screen.dart';
import 'package:swamper_solution/views/individual_views/edit_kyc_screen.dart';
import 'package:swamper_solution/views/individual_views/kyc_status_screen.dart';
import 'package:swamper_solution/views/individual_views/kyc_verified_screen.dart';
import 'package:swamper_solution/views/individual_views/notification_screen.dart';
import 'package:swamper_solution/views/common/landing_screen.dart';
import 'package:swamper_solution/views/common/login_screen/login_screen.dart';
import 'package:swamper_solution/views/common/reset_password_screen.dart';
import 'package:swamper_solution/views/common/signup_screen/signup_screen.dart';
import 'package:swamper_solution/views/individual_views/one_time_resume_upload_screen.dart';
import 'package:swamper_solution/views/individual_views/profile_screen.dart';
import 'package:swamper_solution/views/individual_views/users_main_screen.dart';
import 'package:swamper_solution/views/company_views/company_main_screen.dart';

class AppRouteConfig {
  AppRouteConfig();

  static String? _cachedUserRole;
  static String? _cachedUserId;
  static DateTime? _lastCacheTime;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  late final GoRouter appRoutes = GoRouter(
    initialLocation: '/',
    redirect: _handleRedirect,
    routes: [
      GoRoute(
        path: "/email_varification_screen",
        name: "email_varification_screen",
        builder: (context, state) {
          return const EmailVerificationScreen();
        },
      ),
      GoRoute(
        path: "kyc_status_screen",
        name: "kyc_status_screen",
        builder: (context, state) {
          return KycStatusScreen();
        },
      ),

      GoRoute(
        path: "kyc_verified_screen",
        name: "kyc_verified_screen",
        builder: (context, state) {
          return KycVerifiedScreen();
        },
      ),
      // Auth routes
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: '/reset_password',
        name: 'reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // Individual user routes
      GoRoute(
        path: '/individual',
        builder: (context, state) => const UsersMainScreen(),
        routes: [
          GoRoute(
            path: "profile_screen",
            name: "profile_screen",
            builder: (context, state) {
              return ProfileScreen();
            },
          ),
          GoRoute(
            path: 'job_details',
            name: 'individual_job_details',

            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>;
              final job = data['job'] as JobModel;
              final user = data['user'] as IndividualModel;
              return JobDetailsScreen(jobDetails: job, userData: user);
            },
          ),
          GoRoute(
            path: 'job_offer_screen',
            name: 'job_offer_screen',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>;
              final job = data['job'] as JobModel;
              final user = data['user'] as IndividualModel;
              return JobOfferScreen(jobDetails: job, userData: user);
            },
          ),
          GoRoute(
            path: 'current_job_details_screen',
            name: 'current_job_details_screen',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>;
              final jobApplication =
                  data['jobApplication'] as JobApplicationModel;
              final user = data['user'] as IndividualModel;
              final selectedDate = data['selectedDate'] as DateTime?;
              return CurrentJobDetailsScreen(
                jobApplicationData: jobApplication,
                userData: user,
                selectedDate: selectedDate,
              );
            },
          ),
          GoRoute(
            path: "individual_kyc_application_screen",
            name: "individual_kyc_application_screen",
            builder: (context, state) {
              return IndividualKycApplicationScreen();
            },
          ),
          GoRoute(
            path: "verified_kyc_application_screen",
            name: "verified_kyc_application_screen",
            builder: (context, state) {
              return KycVerifiedScreen();
            },
          ),

          GoRoute(
            path: "contact_admin_screen",
            name: "contact_admin_screen",
            builder: (context, state) {
              return AdminContactScreen();
            },
          ),
          GoRoute(
            path: 'notifications',
            name: 'notifications',

            builder: (context, state) {
              return NotificationScreen();
            },
          ),
          GoRoute(
            path: 'kyc_review',
            name: 'kyc_review',
            builder: (context, state) => const KycReviewScreen(),
          ),
          GoRoute(
            path: 'edit_kyc',
            name: 'edit_kyc',
            builder: (context, state) => const EditKycScreen(),
          ),
          GoRoute(
            path: "one_time_resume_upload_screen",
            name: "one_time_resume_upload_screen",
            builder: (context, state) => const OneTimeResumeUploadScreen(),
          ),
          GoRoute(
            path: "/delete_account",
            name: "delete_account",
            builder: (context, state) {
              return DeleteAccountScreen();
            },
          ),
        ],
      ),

      // Company routes
      GoRoute(
        path: '/company',
        builder: (context, state) => const CompanyMainScreen(),
        routes: [
          GoRoute(
            path: 'job_posting_screen/:job_role',
            name: 'job_posting_screen',

            builder: (context, state) {
              final companyData = state.extra as CompanyModel;
              return JobPostingScreen(
                companyData: companyData,
                jobRole: state.pathParameters['job_role']!,
              );
            },
          ),

          GoRoute(
            path: 'posted_jobs_screen',
            name: 'posted_jobs_screen',

            builder: (context, state) {
              return JobsScreen();
            },
          ),

          GoRoute(
            path: 'company_notifications',
            name: 'company_notifications',

            builder: (context, state) {
              return NotificationScreen();
            },
          ),

          // Company's listed job details screen
          GoRoute(
            path: 'posted_job_details',
            name: 'posted_job_details',

            builder: (context, state) {
              final job = state.extra as JobModel;
              return PostedJobDetailsScreen(job);
            },
          ),

          // Edit Job Screen
          GoRoute(
            path: 'edit_job',
            name: 'edit_job',

            builder: (context, state) {
              final job = state.extra as JobModel;
              return EditJobScreen(jobDetails: job);
            },
          ),

          GoRoute(
            path: "/delete_company_account",
            name: "delete_company_account",
            builder: (context, state) {
              return DeleteCompanyAccountScreen();
            },
          ),
        ],
      ),
    ],
  );

  Future<String?> _handleRedirect(context, state) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // If user is already logged in
    if (auth.currentUser != null) {
      final currentUserId = auth.currentUser!.uid;

      // Check if email is verified
      if (!auth.currentUser!.emailVerified) {
        // Allow access to email verification screen
        if (state.matchedLocation == '/email_varification_screen' ||
            state.name == 'email_varification_screen') {
          return null;
        }
        return '/email_varification_screen';
      }

      // Don't redirect if already on correct path
      if (state.matchedLocation.startsWith('/individual') ||
          state.matchedLocation.startsWith('/company')) {
        return null;
      }

      // Check cache first to avoid repeated Firebase calls
      final now = DateTime.now();
      if (_cachedUserId == currentUserId &&
          _lastCacheTime != null &&
          now.difference(_lastCacheTime!).compareTo(_cacheExpiry) < 0 &&
          _cachedUserRole != null) {
        debugPrint('Using cached user role: $_cachedUserRole');
        return _cachedUserRole == 'Individual' ? '/individual' : '/company';
      }

      try {
        final userDoc =
            await firestore.collection('profiles').doc(currentUserId).get();
        if (!userDoc.exists) {
          // Profile deleted or not found, delete auth account and force logout
          try {
            await auth.currentUser!.delete();
          } catch (deleteError) {
            debugPrint('Error deleting user in redirect: $deleteError');
          }
          await auth.signOut();
          AppRouteConfig.clearCache();
          return '/';
        }
        final role = userDoc.data()?['role'] as String?;

        // Update cache
        _cachedUserId = currentUserId;
        _cachedUserRole = role;
        _lastCacheTime = now;

        if (role == 'Individual') {
          return '/individual';
        } else if (role == 'Company') {
          return '/company';
        } else {
          // Invalid role, delete auth account and force logout
          try {
            await auth.currentUser!.delete();
          } catch (deleteError) {
            debugPrint('Error deleting user with invalid role: $deleteError');
          }
          await auth.signOut();
          AppRouteConfig.clearCache();
          return '/';
        }
      } catch (e) {
        // On error, delete auth account and force logout
        debugPrint('Error in redirect: $e');
        try {
          await auth.currentUser!.delete();
        } catch (deleteError) {
          debugPrint('Error deleting user in error handler: $deleteError');
        }
        await auth.signOut();
        AppRouteConfig.clearCache();
        return '/';
      }
    } else {
      // User not logged in, clear cache
      AppRouteConfig.clearCache();
    }

    // If user is not logged in, only allow access to login, signup, and reset_password
    if (!(state.matchedLocation == '/' ||
        state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/signup') ||
        state.matchedLocation.startsWith('/email_varification_screen') ||
        state.matchedLocation.startsWith('/reset_password'))) {
      return '/';
    }
    return null;
  }

  static void clearCache() {
    _cachedUserRole = null;
    _cachedUserId = null;
    _lastCacheTime = null;
  }
}
