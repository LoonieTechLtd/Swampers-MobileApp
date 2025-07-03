import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/services/auth_services.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/edit_profile_dialouge.dart';
import 'package:swamper_solution/views/custom_widgets/kyc_status.dart';
import 'package:swamper_solution/views/custom_widgets/log_out_button.dart';
import 'package:swamper_solution/views/custom_widgets/user_data_tile.dart';

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
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    // Responsive values
    final horizontalPadding =
        isLargeScreen
            ? screenWidth * 0.2
            : isTablet
            ? screenWidth * 0.1
            : 16.0;
    final avatarRadius = isTablet ? 80.0 : 60.0;
    final maxContentWidth = isLargeScreen ? 600.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("My Profile")),

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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return RefreshIndicator(
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile Avatar with cached network image
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundColor: Colors.grey[200],
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: user.profilePic,
                                      width: avatarRadius * 2,
                                      height: avatarRadius * 2,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Container(
                                            width: avatarRadius * 2,
                                            height: avatarRadius * 2,
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.person,
                                              size: avatarRadius * 0.8,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Container(
                                            width: avatarRadius * 2,
                                            height: avatarRadius * 2,
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.person,
                                              size: avatarRadius * 0.8,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ),

                              Consumer(
                                builder: (context, ref, child) {
                                  final kycAsnc = ref.watch(kycStatusProvider);
                                  return kycAsnc.when(
                                    data: (exists) {
                                      return KycStatus(
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
                                      );
                                    },
                                    error: (error, stack) {
                                      return KycStatus(
                                        data: user,
                                        onTap: () {},
                                      );
                                    },
                                    loading: () {
                                      return KycStatus(
                                        data: user,
                                        onTap:
                                            () {}, // Disable tap while loading
                                      );
                                    },
                                  );
                                },
                              ),

                              // User Data Tiles with responsive spacing
                              ...List.generate(5, (index) {
                                final tiles = [
                                  UserDataTile(
                                    title: "Name",
                                    value: "${user.firstName} ${user.lastName}",
                                    icon: FeatherIcons.user,
                                  ),
                                  UserDataTile(
                                    title: "Email",
                                    value: user.email,
                                    icon: FeatherIcons.mail,
                                  ),

                                  UserDataTile(
                                    title: "Address",
                                    value: user.address,
                                    icon: FeatherIcons.mapPin,
                                  ),
                                  UserDataTile(
                                    title: "Password",
                                    value: "**********",
                                    icon: FeatherIcons.lock,
                                  ),
                                  UserDataTile(
                                    title: "Contact",
                                    value: user.contactNo,
                                    icon: FeatherIcons.phone,
                                  ),
                                ];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: screenHeight * 0.015,
                                  ),
                                  child: tiles[index],
                                );
                              }),

                              SizedBox(height: screenHeight * 0.04),

                              // Buttons with responsive layout
                              if (isTablet && screenWidth > 800) ...[
                                // Side by side layout for large screens
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        backgroundColor: Colors.blue,
                                        onPressed:
                                            () => _handleEditProfile(
                                              context,
                                              ref,
                                              user,
                                              firstNameController,
                                              lastNameController,
                                              phoneNumberController,
                                              addressController,
                                            ),
                                        text: "Edit Profile",
                                        textColor: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: LogOutButton(
                                        onTap:
                                            () => _handleLogout(context, ref),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // Stacked layout for smaller screens
                                CustomButton(
                                  backgroundColor: Colors.blue,
                                  onPressed:
                                      () => _handleEditProfile(
                                        context,
                                        ref,
                                        user,
                                        firstNameController,
                                        lastNameController,
                                        phoneNumberController,
                                        addressController,
                                      ),
                                  text: "Edit Profile",
                                  textColor: Colors.white,
                                ),
                                SizedBox(height: 16),
                                LogOutButton(
                                  onTap: () => _handleLogout(context, ref),
                                ),
                              ],

                              SizedBox(height: screenHeight * 0.02),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          error: (error, stack) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: isTablet ? 80 : 60,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Error occurred",
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "$error",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => ref.refresh(individualProvider),
                      icon: Icon(Icons.refresh),
                      label: Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 20,
                          vertical: isTablet ? 16 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: isTablet ? 60 : 50,
                    height: isTablet ? 60 : 50,
                    child: CircularProgressIndicator(
                      strokeWidth: isTablet ? 4 : 3,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Loading profile...",
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleEditProfile(
    BuildContext context,
    WidgetRef ref,
    dynamic user, // Replace with your actual user model type
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(isTablet ? 32 : 24),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: isTablet ? 28 : 24),
              SizedBox(width: 12),
              Text(
                "Log Out?",
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to log out? You'll need to sign in again to access your account.",
            style: CustomTextStyles.description.copyWith(
              fontSize: isTablet ? 16 : 14,
            ),
          ),
          actionsPadding: EdgeInsets.only(
            left: isTablet ? 32 : 24,
            right: isTablet ? 32 : 24,
            bottom: isTablet ? 24 : 16,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => AuthServices().logout(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout,
                    size: isTablet ? 18 : 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Log Out",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
