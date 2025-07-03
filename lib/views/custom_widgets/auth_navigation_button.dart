import 'package:flutter/material.dart';

class AuthNavigationButton extends StatelessWidget {
  final String prefixText;
  final String buttonText;
  final VoidCallback onTap;
  const AuthNavigationButton({
    super.key,
    required this.prefixText,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        Text(prefixText),
        InkWell(
          onTap: onTap,
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
