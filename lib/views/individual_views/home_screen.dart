import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_controller.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_choice_chip.dart';
import 'package:swamper_solution/views/custom_widgets/custom_search_bar.dart';
import 'package:swamper_solution/views/custom_widgets/job_post_card.dart';
import 'package:swamper_solution/views/custom_widgets/stat_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedWork = "All Works";
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // drawer list Tile
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 24),
      title: Text(title),
      onTap: onTap,
    );
  }

  // Notification toggle
  Widget _buildNotificationToggle() {
    bool isNotificationEnabled = true;

    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Notifications'),
          value: isNotificationEnabled,
          onChanged: (val) {
            setState(() {
              isNotificationEnabled = val;
            });
          },
          secondary: const Icon(Icons.notifications_active_outlined),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors().primaryColor,
        elevation: 0,
        child: Icon(Icons.headset_mic, color: AppColors().white),
        onPressed: () {
          context.goNamed("contact_admin_screen");
        },
      ),
      drawer: Consumer(
        builder: (context, ref, child) {
          final userAsync = ref.watch(individualProvider);
          return userAsync.when(
            data: (user) {
              return Drawer(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 60,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Header/Profile Section ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: NetworkImage(user!.profilePic),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${user.firstName} ${user.lastName}",
                                style: CustomTextStyles.h3,
                              ),
                              Text(user.email),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildDrawerItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {
                          // Navigate to settings
                        },
                      ),
                      _buildNotificationToggle(),
                      _buildDrawerItem(
                        icon: Icons.work_outline,
                        title: 'My Jobs',
                        onTap: () {
                          // Navigate to my jobs
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.description_outlined,
                        title: 'My Documents',
                        onTap: () {
                          // Navigate to documents
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {
                          // Navigate to about
                        },
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            "App v1.0.0",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Row(
                            children: [
                              Text("Designed and Developed by "),
                              Text(
                                "Loonie Tech",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors().primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            error: (error, stack) {
              return Center(child: Text("Error: $error"));
            },
            loading: () {
              return CircularProgressIndicator();
            },
          );
        },
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color.fromARGB(255, 5, 100, 178),
                    const Color.fromARGB(255, 5, 100, 178),
                    const Color.fromARGB(255, 28, 28, 30),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final userAsync = ref.watch(individualProvider);
                      return userAsync.when(
                        data: (user) {
                          if (user == null) {
                            return Text("No User Found");
                          }
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 12),
                              InkWell(
                                onTap: () {
                                  // Scaffold.of(context).openDrawer();
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    user.profilePic,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.firstName,
                                    style: CustomTextStyles.h5.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Welcome back",
                                    style: CustomTextStyles.description
                                        .copyWith(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  context.go('/individual/notifications');
                                },
                                icon: Icon(
                                  FeatherIcons.bell,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                        error: (error, stack) {
                          return Text("Error lodaing user data");
                        },
                        loading: () {
                          return Center(child: SizedBox());
                        },
                      );
                    },
                  ),

                  // Search Bar Field
                  CustomSearchBar(
                    searchController: searchController,
                    hintText: "Search for job title or location",
                  ),

                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final userStats = ref.watch(getIndividualStats);
                      return userStats.when(
                        data: (data) {
                          if (data == null) {
                            return Center(
                              child: Text("No stats data available"),
                            );
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StatWidget(
                                data: data.totalHours.toString(),
                                label: "Total Hours",
                              ),
                              StatWidget(
                                data: data.totalJobs.toString(),
                                label: "Total Jobs",
                              ),
                              StatWidget(
                                data: data.totalEarning.toString(),
                                label: "Total Earning",
                              ),
                            ],
                          );
                        },
                        error: (error, stack) {
                          return Center(child: Text("Error: $error"));
                        },
                        loading: () {
                          return Center(child: CircularProgressIndicator());
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 14),

            // Choice Chips to filter quickly
            CustomChoiceChip(
              onWorkSelected: (work) {
                setState(() {
                  selectedWork = work;
                });
              },
            ),

            SizedBox(height: 14),

            Consumer(
              builder: (context, ref, child) {
                final jobAsync = ref.watch(getJobProvider);
                final userAsync = ref.watch(individualProvider);
                return userAsync.when(
                  data: (user) {
                    if (user == null) {
                      return Center(child: Text("No User Found"));
                    }
                    return jobAsync.when(
                      data: (jobs) {
                        final filteredJobs =
                            jobs.where((job) {
                              final matchesWork =
                                  selectedWork == "All Works" ||
                                  job.role == selectedWork;
                              final matchesSearch =
                                  searchController.text.trim().isEmpty ||
                                  JobController().searchJob(
                                    job,
                                    searchController.text,
                                  );
                              return matchesSearch && matchesWork;
                            }).toList();

                        return Column(
                          children:
                              filteredJobs
                                  .map(
                                    (job) => JobPostCard(
                                      jobDetails: job,
                                      userDetails: user,
                                    ),
                                  )
                                  .toList(),
                        );
                      },
                      error: (error, stack) {
                        return Center(
                          child: Text("Error Loading Jobs: $error"),
                        );
                      },
                      loading: () {
                        return Center(child: CircularProgressIndicator());
                      },
                    );
                  },
                  error: (error, stack) {
                    return Center(child: Text("Error Loading User: $error"));
                  },
                  loading: () {
                    return Center(child: CircularProgressIndicator());
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
