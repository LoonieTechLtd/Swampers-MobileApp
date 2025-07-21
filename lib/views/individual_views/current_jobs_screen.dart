import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/models/job_application_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_search_bar.dart';

class CurrentJobsScreen extends ConsumerStatefulWidget {
  const CurrentJobsScreen({super.key});

  @override
  ConsumerState<CurrentJobsScreen> createState() => _CurrentJobsScreenState();
}

class _CurrentJobsScreenState extends ConsumerState<CurrentJobsScreen> {
  DateTime todayDate = DateTime.now();
  DateTime? selectedDate;
  List<JobApplicationModel> filteredJobs = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = todayDate; // Initialize with today's date

    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<JobApplicationModel> _filterJobs(
    List<JobApplicationModel> jobs,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) return jobs;

    return jobs.where((jobApplication) {
      final job = jobApplication.jobDetails;
      return job.role.toLowerCase().contains(searchTerm.toLowerCase()) ||
          job.location.toLowerCase().contains(searchTerm.toLowerCase()) ||
          job.description.toLowerCase().contains(searchTerm.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentJobsAsync = ref.watch(getCurrentJobsProvider(selectedDate!));

    return Scaffold(
      appBar: AppBar(title: const Text("My Jobs")),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchBar(
              searchController: searchController,
              hintText: "Search Today's Jobs",
            ),
            EasyDateTimeLine(
              activeColor: AppColors().primaryColor,
              initialDate: todayDate,
              onDateChange: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),

            const SizedBox(height: 16),
            Expanded(
              child: currentJobsAsync.when(
                data: (jobs) {
                  final filteredJobs = _filterJobs(jobs, searchController.text);

                  if (filteredJobs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No jobs found for this date",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final jobApplication = filteredJobs[index];
                      final job = jobApplication.jobDetails;

                      return InkWell(
                        onTap: () async {
                          try {
                            final user = await ref.read(
                              individualProvider.future,
                            );
                            if (user != null) {
                              context.pushNamed(
                                "current_job_details_screen",
                                extra: {
                                  'jobApplication': jobApplication,
                                  'user': user,
                                  'selectedDate':
                                      selectedDate, // Pass the selected date
                                },
                              );
                            } else {
                              // Handle the case where user data couldn't be loaded
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unable to load user data'),
                                ),
                              );
                            }
                          } catch (e) {
                            // Handle any errors during user data loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error loading user data: $e'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.black12),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        job.role,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        jobApplication.applicationStatus,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      job.location,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      jobApplication.selectedShift,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "\$${job.hourlyIncome.toStringAsFixed(0)}/hr",
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (job.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    job.description,
                                    style: TextStyle(color: Colors.grey[700]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Error loading jobs",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
