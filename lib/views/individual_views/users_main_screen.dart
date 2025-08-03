import 'dart:io';

import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button_nav_bar.dart';
import 'package:swamper_solution/views/individual_views/application_screen.dart';
import 'package:swamper_solution/views/individual_views/current_jobs_screen.dart';
import 'package:swamper_solution/views/individual_views/employment_screen.dart';
import 'package:swamper_solution/views/individual_views/home_screen.dart';
import 'package:swamper_solution/views/individual_views/profile_screen.dart';
import 'package:upgrader/upgrader.dart';

class UsersMainScreen extends StatefulWidget {
  const UsersMainScreen({super.key});

  @override
  State<UsersMainScreen> createState() => _UsersMainScreenState();
}

class _UsersMainScreenState extends State<UsersMainScreen> {
  final List<Widget> screens = [
    HomeScreen(),
    CurrentJobsScreen(),
    ApplicationScreen(),
    EmploymentScreen(),
    ProfileScreen(),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      barrierDismissible: false,
      showIgnore: false,
      showLater: false,
      dialogStyle:
          Platform.isIOS
              ? UpgradeDialogStyle.cupertino
              : UpgradeDialogStyle.material,
      showReleaseNotes: false,
      // Add debugDisplayAlways: true to force dialog for testing
      upgrader: Upgrader(
        messages: UpgraderMessages(code: "Update app now!"),

      ),
      child: Scaffold(
        bottomNavigationBar: CustomBottomNavBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(FeatherIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(FeatherIcons.calendar),
              label: 'Todays Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(FeatherIcons.fileText),
              label: 'Applications',
            ),
            BottomNavigationBarItem(
              icon: Icon(FeatherIcons.briefcase),
              label: 'Employment',
            ),
            BottomNavigationBarItem(
              icon: Icon(FeatherIcons.user),
              label: 'Profile',
            ),
          ],
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
        body: screens[currentIndex],
      ),
    );
  }
}
