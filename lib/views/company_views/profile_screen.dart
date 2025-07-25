import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/edit_profile_dialouge.dart';
import 'package:swamper_solution/views/custom_widgets/profile_action_buttons.dart';
import 'package:swamper_solution/views/custom_widgets/profile_header_card.dart';
import 'package:swamper_solution/views/custom_widgets/profile_info_card.dart';
import 'package:swamper_solution/views/custom_widgets/profile_logout_dialog.dart';
import 'package:swamper_solution/views/custom_widgets/profile_password_card.dart';
import 'package:swamper_solution/views/custom_widgets/profile_utils.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController addressController = TextEditingController();

    final userAsync = ref.watch(companyProvider);

    // Get screen dimensions for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    // Responsive values
    final horizontalPadding = isLargeScreen ? screenWidth * 0.15 : 16.0;
    final avatarRadius = isTablet ? 80.0 : 65.0;
    final maxContentWidth = isLargeScreen ? 700.0 : double.infinity;

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
            "Company Profile",
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
              return const Center(child: Text("No Company data available"));
            }
            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(companyProvider);
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
                          const SizedBox(height: 20),
                          ProfileHeaderCard(
                            isCompany: true,
                            companyName: user.companyName,
                            avatarRadius: avatarRadius,
                            isTablet: isTablet,
                            profilePic: user.profilePic,
                            email: user.email,
                          ),

                          const SizedBox(height: 20),

                          // Contact Information
                          const SizedBox(height: 12),
                          ProfileInfoCard(
                            title: "Phone Number",
                            content: user.contactNo,
                            icon: FeatherIcons.phone,
                            iconColor: Colors.green,
                          ),
                          SizedBox(height: 12),
                          // Address Information
                          ProfileInfoCard(
                            title: "Address",
                            content: user.address,
                            icon: FeatherIcons.mapPin,
                            iconColor: Colors.purple,
                          ),

                          const SizedBox(height: 12),
                          ProfilePasswordCard(context: context, ref: ref),
                          const SizedBox(height: 12),
                          ProfileInfoCard(
                            title: "Member Since",
                            content: ProfileUtils.formatDate(user.createdAt),
                            icon: FeatherIcons.calendar,
                            iconColor: Colors.indigo,
                          ),

                          const SizedBox(height: 30),

                          ProfileActionButtons(
                            context: context,
                            ref: ref,
                            user: user,
                            onEditProfile:
                                () => _handleEditProfile(
                                  context,
                                  ref,
                                  user,
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
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: isTablet ? 48 : 40,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Error Loading Profile",
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$error",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(companyProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 20,
                            vertical: isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: isTablet ? 60 : 50,
                      height: isTablet ? 60 : 50,
                      child: CircularProgressIndicator(
                        strokeWidth: isTablet ? 4 : 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Loading profile...",
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    ProfileLogoutDialog.show(context, ref);
  }

  void _handleEditProfile(
    BuildContext context,
    WidgetRef ref,
    CompanyModel user,
    TextEditingController addressController,
  ) {
    final TextEditingController companyNameController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

    companyNameController.text = user.companyName;
    phoneNumberController.text = user.contactNo;
    addressController.text = user.address;

    EditProfileDialouge().editProfileDialouge(
      context,
      ref,
      user,
      companyNameController,
      null, // lastNameController (not needed for company)
      phoneNumberController,
      addressController,
    );
  }
}
