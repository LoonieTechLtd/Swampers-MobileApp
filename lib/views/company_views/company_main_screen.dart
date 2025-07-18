import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/views/company_views/admin_contact_screen.dart';
import 'package:swamper_solution/views/company_views/jobs_screen.dart';
import 'package:swamper_solution/views/company_views/home_screen.dart';
import 'package:swamper_solution/views/company_views/profile_screen.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button_nav_bar.dart';

class CompanyMainScreen extends StatefulWidget {
  const CompanyMainScreen({super.key});

  @override
  State<CompanyMainScreen> createState() => _CompanyMainScreenState();
}

class _CompanyMainScreenState extends State<CompanyMainScreen> {
  int currentIndex = 0;
  List<Widget> screens = [
    HomeScreen(),
    JobsScreen(),
    AdminContactScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(FeatherIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.briefcase),
            label: 'Posted Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.headphones),
            label: 'Admin Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.user),
            label: 'Profile',
          ),
        ],
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
