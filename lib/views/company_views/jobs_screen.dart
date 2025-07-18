import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_search_bar.dart';
import 'package:swamper_solution/views/custom_widgets/posted_jobs_card.dart';

class JobsScreen extends StatelessWidget {
  JobsScreen({super.key});
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Posted Jobs"), centerTitle: true),
      body: SafeArea(
        child: ListView(
          children: [
            CustomSearchBar(
              searchController: searchController,
              color: Colors.black12,
              hintText: "Search Your Jobs",
            ),
            Consumer(
              builder: (context, ref, child) {
                final companyJobsAsync = ref.watch(getCompanyJobProvider);
                return companyJobsAsync.when(
                  data: (jobs) {
                    if (jobs.isEmpty) {
                      return Center(child: Text("You haven't posted any Jobs"));
                    }
                    for (final job in jobs) {
                      debugPrint(job.toString());
                    }
                    
                    return Column(
                      children:
                          jobs
                              .map((job) => PostedJobsCard(jobDetails: job))
                              .toList(),
                    );
                  },
                  error: (error, stack) {
                    return Center(child: Text("Error: ${error.toString()}"));
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

class CompanyJobsListWidget extends StatelessWidget {
  final JobModel jobDetails;
  const CompanyJobsListWidget({super.key, required this.jobDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      child: Stack(
        children: [
          /// Main Row: Avatar + Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      jobDetails.role,
                      style: CustomTextStyles.h4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jobDetails.postedDate,
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// Positioned Badge: Bottom Right Corner
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green,
              ),
              child: Row(
                children: const [
                  Icon(FeatherIcons.check, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text("Approved", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
