import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/log_out_button.dart';

class ProfileActionButtons extends StatelessWidget {
  final BuildContext context;
  final WidgetRef ref;
  final dynamic user;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;
  final bool isTablet;
  final double screenWidth;

  const ProfileActionButtons({
    super.key,
    required this.context,
    required this.ref,
    required this.user,
    required this.onEditProfile,
    required this.onLogout,
    required this.isTablet,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          if (_shouldUseSideBySideLayout()) ...[
            _buildSideBySideLayout(),
          ] else ...[
            _buildStackedLayout(),
          ],
        ],
      ),
    );
  }

  bool _shouldUseSideBySideLayout() {
    return isTablet && screenWidth > 800;
  }

  Widget _buildSideBySideLayout() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            backgroundColor: Colors.blue,
            onPressed: onEditProfile,
            text: "Edit Profile",
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: LogOutButton(onTap: onLogout)),
      ],
    );
  }

  Widget _buildStackedLayout() {
    return Column(
      children: [
        CustomButton(
          backgroundColor: Colors.blue,
          onPressed: onEditProfile,
          text: "Edit Profile",
          textColor: Colors.white,
        ),
        const SizedBox(height: 12),
        LogOutButton(onTap: onLogout),
      ],
    );
  }
}
