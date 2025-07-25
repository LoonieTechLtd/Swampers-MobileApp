import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

class ProfileHeaderCard extends StatelessWidget {
  final bool isCompany;
  final String profilePic;
  final String email;
  final String? companyName;
  final String? firstName;
  final String? lastName;
  final double avatarRadius;
  final bool isTablet;

  const ProfileHeaderCard({
    super.key,
    required this.isCompany,
    required this.avatarRadius,
    required this.isTablet,
    required this.profilePic,
    required this.email,
    this.companyName,
    this.firstName,
    this.lastName,
  }) : assert(
         (isCompany && companyName != null) ||
             (!isCompany && firstName != null && lastName != null),
         'If isCompany is true, companyName must be provided. '
         'If isCompany is false, both firstName and lastName must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileAvatar(),
          const SizedBox(height: 10),
          _buildUserName(),
          const SizedBox(height: 8),
          _buildUserEmail(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: avatarRadius,
        backgroundColor: Colors.grey[100],
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profilePic,
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(),
            errorWidget: (context, url, error) => _buildPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: avatarRadius * 2,
      height: avatarRadius * 2,
      color: Colors.grey[100],
      child: Icon(
        Icons.person,
        size: avatarRadius * 0.8,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildUserName() {
    return isCompany
        ? Text(
          companyName!,
          style: CustomTextStyles.h2.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        )
        : Text(
          "$firstName $lastName",
          style: CustomTextStyles.h2.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        );
  }

  Widget _buildUserEmail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        email,
        style: CustomTextStyles.bodyText.copyWith(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
