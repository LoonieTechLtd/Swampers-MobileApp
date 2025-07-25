import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/edit_profile_dialouge.dart';
import 'package:swamper_solution/views/custom_widgets/kyc_status.dart';
import 'package:swamper_solution/views/custom_widgets/profile_header_card.dart';
import 'package:swamper_solution/views/custom_widgets/profile_info_card.dart';
import 'package:swamper_solution/views/custom_widgets/profile_password_card.dart';
import 'package:swamper_solution/views/custom_widgets/profile_action_buttons.dart';
import 'package:swamper_solution/views/custom_widgets/profile_error_state.dart';
import 'package:swamper_solution/views/custom_widgets/profile_loading_state.dart';
import 'package:swamper_solution/views/custom_widgets/profile_logout_dialog.dart';
import 'package:swamper_solution/views/custom_widgets/profile_utils.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    final userAsync = ref.watch(individualProvider);

    // Get screen dimensions for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = ProfileUtils.isTabletScreen(screenWidth);
    final isLargeScreen = ProfileUtils.isLargeScreen(screenWidth);

    // Responsive values
    final horizontalPadding = ProfileUtils.getHorizontalPadding(
      isLargeScreen,
      screenWidth,
    );
    final avatarRadius = ProfileUtils.getAvatarRadius(isTablet);
    final maxContentWidth = ProfileUtils.getMaxContentWidth(isLargeScreen);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "My Profile",
            style: CustomTextStyles.h4.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: userAsync.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          data: (user) {
            if (user == null) {
              return const Center(child: Text("No user data available"));
            }
            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(individualProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20), // Space for app bar
                          // Profile Header Card
                          ProfileHeaderCard(
                            isCompany: false,
                            firstName: user.firstName,
                            lastName: user.lastName,
                            avatarRadius: avatarRadius,
                            isTablet: isTablet,
                            profilePic: user.profilePic,
                            email: user.email,
                          ),

                          const SizedBox(height: 20),

                          // KYC Status
                          Consumer(
                            builder: (context, ref, child) {
                              final kycAsync = ref.watch(kycStatusProvider);
                              return kycAsync.when(
                                data: (exists) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: KycStatus(
                                      data: user,
                                      onTap: () {
                                        if (exists) {
                                          context.pushNamed(
                                            "kyc_status_screen",
                                          );
                                        } else {
                                          context.pushNamed(
                                            "individual_kyc_application_screen",
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                                error: (error, stack) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: KycStatus(data: user, onTap: () {}),
                                  );
                                },
                                loading: () {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: KycStatus(data: user, onTap: () {}),
                                  );
                                },
                              );
                            },
                          ),

                          // Contact Information
                          ProfileInfoCard(
                            title: "Phone Number",
                            content: user.contactNo,
                            icon: FeatherIcons.phone,
                            iconColor: Colors.green,
                          ),
                          const SizedBox(height: 12),

                          // Address Information
                          ProfileInfoCard(
                            title: "Address",
                            content: user.address,
                            icon: FeatherIcons.mapPin,
                            iconColor: Colors.purple,
                          ),
                          const SizedBox(height: 12),

                          // Password Card with Change Button
                          ProfilePasswordCard(context: context, ref: ref),
                          const SizedBox(height: 12),

                          // Work Interest
                          ProfileInfoCard(
                            title: "Interested Work",
                            content: user.interestedWork,
                            icon: FeatherIcons.briefcase,
                            iconColor: Colors.orange,
                          ),
                          const SizedBox(height: 12),

                          // Account Created
                          ProfileInfoCard(
                            title: "Member Since",
                            content: ProfileUtils.formatDate(user.createdAt),
                            icon: FeatherIcons.calendar,
                            iconColor: Colors.indigo,
                          ),

                          const SizedBox(height: 30),

                          // Action Buttons
                          ProfileActionButtons(
                            context: context,
                            ref: ref,
                            user: user,
                            onEditProfile:
                                () => _handleEditProfile(
                                  context,
                                  ref,
                                  user,
                                  firstNameController,
                                  lastNameController,
                                  phoneNumberController,
                                  addressController,
                                ),
                            onLogout: () => _handleLogout(context, ref),
                            isTablet: isTablet,
                            screenWidth: screenWidth,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          error: (error, stack) {
            return ProfileErrorState(
              error: error,
              stack: stack,
              onRetry: () => ref.refresh(individualProvider),
              horizontalPadding: horizontalPadding,
              isTablet: isTablet,
            );
          },
          loading: () {
            return ProfileLoadingState(isTablet: isTablet);
          },
        ),
      ),
    );
  }

  void _handleEditProfile(
    BuildContext context,
    WidgetRef ref,
    IndividualModel user, // Replace with your actual user model type
    TextEditingController firstNameController,
    TextEditingController lastNameController,
    TextEditingController phoneNumberController,
    TextEditingController addressController,
  ) {
    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    phoneNumberController.text = user.contactNo;
    addressController.text = user.address;

    EditProfileDialouge().editProfileDialouge(
      context,
      ref,
      user,
      firstNameController,
      lastNameController,
      phoneNumberController,
      addressController,
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    ProfileLogoutDialog.show(context, ref);
  }
}
