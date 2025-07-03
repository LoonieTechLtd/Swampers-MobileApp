import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/applied_jobs_card.dart';
import 'package:swamper_solution/views/custom_widgets/saved_jobs_list_widget.dart';

class ApplicationScreen extends StatelessWidget {
  const ApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Applications", style: CustomTextStyles.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Consumer(
                builder: (context, ref, child) {
                  final isSelected = ref.watch(applicationProvider);
                  return Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black45, width: 0.8),
                    ),
                    child: ToggleButtons(
                      isSelected: isSelected,
                      borderRadius: BorderRadius.circular(30),
                      selectedColor: Colors.white,
                      fillColor: Colors.blue,
                      color: Colors.blue,
                      borderColor: Colors.transparent,
                      selectedBorderColor: Colors.transparent,
                      constraints: BoxConstraints(
                        minHeight: 50.0,
                        minWidth: MediaQuery.of(context).size.width * 0.3,
                      ),
                      onPressed: (int index) {
                        List<bool> newSelection = List.generate(
                          2,
                          (i) => i == index,
                        );
                        ref.read(applicationProvider.notifier).state =
                            newSelection;
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Applied Jobs",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Saved Jobs",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final isSelected = ref.watch(applicationProvider);
                return isSelected[0]
                    ? Expanded(
                      child: ref
                          .watch(getUserApplicationsProvider)
                          .when(
                            data: (applications) {
                              if (applications.isEmpty) {
                                return Center(child: Text("No Job Applied"));
                              }
                              return ListView.builder(
                                itemCount: applications.length,
                                itemBuilder: (context, index) {
                                  return AppliedJobsCard(
                                    jobApplicationDetails: applications[index],
                                  );
                                },
                              );
                            },
                            error: (error, stack) {
                              return Center(
                                child: Text("Error Loading your applications"),
                              );
                            },
                            loading: () {
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                    )
                    : Expanded(
                      child: ref
                          .watch(getAllSavedJobsProvider)
                          .when(
                            data: (jobs) {
                              if (jobs.isEmpty) {
                                return Center(child: Text(" No Saved Jobs"));
                              }
                              return ListView.builder(
                                itemCount: jobs.length,
                                itemBuilder: (context, index) {
                                  return SavedJobsListWidget(job: jobs[index]);
                                },
                              );
                            },
                            error: (error, stack) {
                              return Center(child: Text('Error: $error'));
                            },
                            loading: () {
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
