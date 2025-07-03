import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/views/common/message_screen.dart';
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
    MessageScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color.fromARGB(255, 0, 4, 217),
      //   shape: CircleBorder(),
      //   elevation: 0,
      //   tooltip: "Post a Job",
      //   onPressed: () {
      //     context.go("/company/job_posting_screen");
      //   },
      //   child: Icon(Icons.add, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(FeatherIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.briefcase),
            label: 'Posted Jobs',
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
