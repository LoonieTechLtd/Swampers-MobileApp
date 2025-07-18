import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/views/company_views/admin_contact_screen.dart';
import 'package:swamper_solution/views/company_views/edit_job_screen.dart';
import 'package:swamper_solution/views/company_views/job_posting_screen.dart';
import 'package:swamper_solution/views/company_views/jobs_screen.dart';
import 'package:swamper_solution/views/company_views/posted_job_details_screen.dart';
import 'package:swamper_solution/views/individual_views/individual_kyc_application_screen.dart';
import 'package:swamper_solution/views/individual_views/job_details_screen.dart';
import 'package:swamper_solution/views/individual_views/job_offer_screen.dart';
import 'package:swamper_solution/views/individual_views/kyc_review_screen.dart';
import 'package:swamper_solution/views/individual_views/edit_kyc_screen.dart';
import 'package:swamper_solution/views/individual_views/kyc_status_screen.dart';
import 'package:swamper_solution/views/individual_views/notification_screen.dart';
import 'package:swamper_solution/views/common/landing_screen.dart';
import 'package:swamper_solution/views/common/login_screen/login_screen.dart';
import 'package:swamper_solution/views/common/reset_password_screen.dart';
import 'package:swamper_solution/views/common/signup_screen/signup_screen.dart';
import 'package:swamper_solution/views/individual_views/users_main_screen.dart';
import 'package:swamper_solution/views/company_views/company_main_screen.dart';

class AppRouteConfig {
  AppRouteConfig();

  late final GoRouter appRoutes = GoRouter(
    initialLocation: '/',
    redirect: _handleRedirect,
    routes: [

      GoRoute(
            path: "kyc_status_screen",
            name: "kyc_status_screen",
            builder: (context, state) {
              return KycStatusScreen();
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
            path: "individual_kyc_application_screen",
            name: "individual_kyc_application_screen",
            builder: (context, state) {
              return IndividualKycApplicationScreen();
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
        ],
      ),
    ],
  );

  Future<String?> _handleRedirect(context, state) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // If user is already logged in
    if (auth.currentUser != null) {
      // Don't redirect if already on correct path
      if (state.matchedLocation.startsWith('/individual') ||
          state.matchedLocation.startsWith('/company')) {
        return null;
      }
      try {
        final userDoc =
            await firestore
                .collection('profiles')
                .doc(auth.currentUser!.uid)
                .get();
        if (!userDoc.exists) {
          // Profile deleted or not found, force logout
          await auth.signOut();
          return '/';
        }
        final role = userDoc.data()?['role'] as String?;
        if (role == 'Individual') {
          return '/individual';
        } else if (role == 'Company') {
          return '/company';
        } else {
          // Invalid role, force logout
          await auth.signOut();
          return '/';
        }
      } catch (e) {
        // On error, force logout
        await auth.signOut();
        return '/';
      }
    }
    // If user is not logged in, only allow access to login, signup, and reset_password
    if (!(state.matchedLocation == '/' ||
        state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/signup') ||
        state.matchedLocation.startsWith('/email_verification') ||
        state.matchedLocation.startsWith('/reset_password'))) {
      return '/';
    }
    return null;
  }
}
