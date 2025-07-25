import 'package:flutter/material.dart';

class ProfileErrorState extends StatelessWidget {
  final Object error;
  final StackTrace stack;
  final VoidCallback onRetry;
  final double horizontalPadding;
  final bool isTablet;

  const ProfileErrorState({
    super.key,
    required this.error,
    required this.stack,
    required this.onRetry,
    required this.horizontalPadding,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildErrorIcon(),
              const SizedBox(height: 16),
              _buildErrorTitle(),
              const SizedBox(height: 8),
              _buildErrorMessage(),
              const SizedBox(height: 24),
              _buildRetryButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Container(
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
    );
  }

  Widget _buildErrorTitle() {
    return Text(
      "Error Loading Profile",
      style: TextStyle(
        fontSize: isTablet ? 24 : 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      "$error",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.grey[600]),
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: const Text("Retry"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
