import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/services/auth_services.dart';
import 'package:swamper_solution/controllers/user_controller.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/log_out_button.dart';
import 'package:swamper_solution/views/custom_widgets/user_data_tile.dart';
import 'package:swamper_solution/views/custom_widgets/edit_profile_dialouge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController companyNameController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final userAsync = ref.watch(companyProvider);

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
      appBar: AppBar(
        centerTitle: true,
        title: Text("Company  Profile"),
        actions: [IconButton(onPressed: () {}, icon: Icon(FeatherIcons.menu))],
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return RefreshIndicator(
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile Avatar
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
                              SizedBox(height: screenHeight * 0.03),
                              
                              // User Data Tiles with responsive spacing
                              ...List.generate(5, (index) {
                                final tiles = [
                                  UserDataTile(
                                    title: "Company Name",
                                    value: user.companyName,
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
                                              companyNameController,
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
                                        companyNameController,
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
                      "Error occurred: $error",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
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
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Loading profile...",
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
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
    CompanyModel user,
    TextEditingController companyNameController,
    TextEditingController phoneNumberController,
    TextEditingController addressController,
  ) {
    companyNameController.text = user.companyName;
    phoneNumberController.text = user.contactNo;
    addressController.text = user.address;
    EditProfileDialouge().editProfileDialouge(
      context,
      ref,
      user,
      companyNameController,
      null, // lastNameController not needed for company
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

  Future<dynamic> updateProfileDialog(
    BuildContext context,
    WidgetRef ref,
    CompanyModel companyData,
    final TextEditingController companyNameController,
    final TextEditingController phoneNumberController,
    final TextEditingController addressController,
  ) {
    final ValueNotifier<String> profilePicNotifier = ValueNotifier(
      companyData.profilePic,
    );

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final dialogWidth = isTablet ? screenWidth * 0.6 : screenWidth * 0.9;
    final avatarRadius = isTablet ? 80.0 : 60.0;

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: screenHeight * 0.8,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture Section
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          final url = await UserController().uploadProfilePic(
                            companyData.uid,
                            picked,
                          );
                          if (url != null) {
                            profilePicNotifier.value = url;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to upload image')),
                            );
                          }
                        }
                      },
                      child: ValueListenableBuilder<String>(
                        valueListenable: profilePicNotifier,
                        builder: (context, value, _) {
                          return CircleAvatar(
                            backgroundImage: NetworkImage(value),
                            radius: avatarRadius,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Tap to change profile picture",
                      style: CustomTextStyles.caption.copyWith(
                        fontSize: isTablet ? 16 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 32 : 24),

                    // Input Fields
                    _buildResponsiveTextField(
                      controller: companyNameController,
                      label: "Company Name",
                      isTablet: isTablet,
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    _buildResponsiveTextField(
                      controller: addressController,
                      label: "Address",
                      isTablet: isTablet,
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    _buildResponsiveTextField(
                      controller: phoneNumberController,
                      label: "Phone Number",
                      isTablet: isTablet,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: isTablet ? 40 : 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 16 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => context.pop(),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 18 : 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 20 : 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 16 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final updatedCompanyData = companyData.copyWith(
                                companyName: companyNameController.text,
                                contactNo: phoneNumberController.text,
                                address: addressController.text,
                                profilePic: profilePicNotifier.value,
                              );

                              await UserController().updateCompanyProfile(
                                updatedCompanyData,
                              );

                              ref.invalidate(companyProvider);
                              context.pop();
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 18 : 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveTextField({
    required TextEditingController controller,
    required String label,
    required bool isTablet,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: isTablet ? 18 : 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 16 : 12,
        ),
      ),
    );
  }
}
