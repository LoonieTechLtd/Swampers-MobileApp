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

  Widget _buildJobDetailRow(
    IconData icon,
    String text,
    Color iconColor, {
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isHighlighted ? iconColor : Colors.grey[700],
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentJobsAsync = ref.watch(getCurrentJobsProvider(selectedDate!));

    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      appBar: AppBar(
        title: const Text(
          "My Jobs",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with search and date picker
            Container(
              color: AppColors().backgroundColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: CustomSearchBar(
                      fillColor: const Color.fromARGB(14, 0, 0, 0),
                      searchController: searchController,
                      hintText: "Search today's job",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: EasyDateTimeLine(
                      activeColor: AppColors().primaryColor,
                      initialDate: todayDate,
                      onDateChange: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      headerProps: EasyHeaderProps(
                        monthPickerType: MonthPickerType.switcher,
                        showHeader: true,
                        selectedDateStyle: TextStyle(
                          color: AppColors().primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      dayProps: EasyDayProps(
                        dayStructure: DayStructure.dayStrDayNum,
                        activeDayStyle: DayStyle(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors().primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors().primaryColor.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        inactiveDayStyle: DayStyle(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                        ),
                        todayStyle: DayStyle(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors().primaryColor.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors().primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: currentJobsAsync.when(
                data: (jobs) {
                  final filteredJobs = _filterJobs(jobs, searchController.text);

                  if (filteredJobs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.work_off_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "No jobs found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try selecting a different date or adjusting your search",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    color: Colors.grey[50],
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                                    'selectedDate': selectedDate,
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Unable to load user data',
                                    ),
                                    backgroundColor: Colors.red[400],
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error loading user data: $e'),
                                  backgroundColor: Colors.red[400],
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
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
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row with title and status
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          job.role,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.green[400]!,
                                              Colors.green[600]!,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          jobApplication.applicationStatus,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Job details with improved icons and spacing
                                  _buildJobDetailRow(
                                    Icons.location_on_outlined,
                                    job.location,
                                    AppColors().primaryColor,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildJobDetailRow(
                                    Icons.access_time_outlined,
                                    jobApplication.selectedShift,
                                    Colors.orange[600]!,
                                  ),
                                  const SizedBox(height: 10),

                                  // Description with improved styling
                                  if (job.description.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        job.description,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],

                                  // Action hint
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Tap for details",
                                        style: TextStyle(
                                          color: AppColors().primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: AppColors().primaryColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading:
                    () => Container(
                      color: Colors.grey[50],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              "Loading your jobs...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                error:
                    (error, stack) => Container(
                      color: Colors.grey[50],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Oops! Something went wrong",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                "We couldn't load your jobs. Please try again.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => setState(() {}),
                              icon: const Icon(Icons.refresh),
                              label: const Text("Try Again"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors().primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
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
