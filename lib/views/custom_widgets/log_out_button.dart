import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class LogOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const LogOutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Icon(FeatherIcons.logOut, color: Colors.red),
            Text("Log Out", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
