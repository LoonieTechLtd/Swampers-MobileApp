import 'package:flutter/material.dart';

class ProfileLoadingState extends StatelessWidget {
  final bool isTablet;

  const ProfileLoadingState({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoadingIndicator(),
            const SizedBox(height: 24),
            _buildLoadingText(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: isTablet ? 60 : 50,
      height: isTablet ? 60 : 50,
      child: CircularProgressIndicator(
        strokeWidth: isTablet ? 4 : 3,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildLoadingText() {
    return Text(
      "Loading profile...",
      style: TextStyle(
        fontSize: isTablet ? 18 : 16,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
