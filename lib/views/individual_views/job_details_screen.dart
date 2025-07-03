import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/individual_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/apply_job_dialogue.dart';

class JobDetailsScreen extends ConsumerWidget {
  final JobModel jobDetails;
  final IndividualModel userData;
  const JobDetailsScreen({
    super.key,
    required this.jobDetails,
    required this.userData,
  });

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4),
      child: Text(title, style: CustomTextStyles.title),
    );
  }

  Widget _spacedDivider() => const Divider(thickness: 1.0, height: 24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController pageController = PageController();
    final ValueNotifier<int> currentPage = ValueNotifier<int>(0);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pop();
        }
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            width: double.infinity,
            child: FloatingActionButton.extended(
              onPressed: () {
                ApplyJobDiaogue().showApplyJobDialouge(
                  context,
                  jobDetails,
                  userData,
                );
              },
              elevation: 0,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              label: Text(
                'Apply for this job',
                style: CustomTextStyles.description.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          title: Text("Job Details"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                ref.read(jobControllerProvider).saveJob(jobDetails.jobId);
              },
              icon: Consumer(
                builder: (context, ref, child) {
                  return StreamBuilder<bool>(
                    stream: ref
                        .watch(jobControllerProvider)
                        .isJobSaved(jobDetails.jobId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Icon(Icons.error, color: Colors.red);
                      }
                      final isSaved = snapshot.data ?? false;
                      return Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.blue,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.36,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: jobDetails.images.length,
                      onPageChanged: (index) => currentPage.value = index,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            placeholder:
                                (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                            imageUrl: jobDetails.images[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          jobDetails.role,
                          style: CustomTextStyles.h3,
                        ),
                      ),
                      Text(
                        "\$ ${jobDetails.hourlyIncome}",
                        style: CustomTextStyles.h3.copyWith(color: Colors.red),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        "/",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text("hr", style: CustomTextStyles.description),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded),
                      const SizedBox(width: 6),
                      Text(
                        jobDetails.location,
                        style: CustomTextStyles.bodyText,
                      ),
                    ],
                  ),
                  _spacedDivider(),
                  _sectionTitle("No of Workers"),
                  Text(
                    jobDetails.noOfWorkers.toString(),
                    style: CustomTextStyles.bodyText,
                  ),
                  _spacedDivider(),
                  _sectionTitle("Shifts"),
                  ...jobDetails.shifts.map(
                    (shift) => Text(shift, style: CustomTextStyles.bodyText),
                  ),
                  _spacedDivider(),
                  _sectionTitle("Job descriptions"),
                  Text(
                    jobDetails.description,
                    style: CustomTextStyles.bodyText,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
