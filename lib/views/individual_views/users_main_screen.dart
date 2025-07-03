import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button_nav_bar.dart';
import 'package:swamper_solution/views/individual_views/application_screen.dart';
import 'package:swamper_solution/views/individual_views/home_screen.dart';
import 'package:swamper_solution/views/common/message_screen.dart';
import 'package:swamper_solution/views/individual_views/profile_screen.dart';

class UsersMainScreen extends StatefulWidget {
  const UsersMainScreen({super.key});

  @override
  State<UsersMainScreen> createState() => _UsersMainScreenState();
}

class _UsersMainScreenState extends State<UsersMainScreen> {
  final List<Widget> screens = [
    HomeScreen(),
    ApplicationScreen(),
    MessageScreen(),
    ProfileScreen(),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(
        items: [
          BottomNavigationBarItem(icon: Icon(FeatherIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.fileText),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.messageCircle),
            label: 'Messages',
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
    );
  }
}
