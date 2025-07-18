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
                        minWidth: MediaQuery.of(context).size.width * 0.26,
                      ),
                      onPressed: (int index) {
          
                        ref
                            .read(applicationProvider.notifier)
                            .state = List.generate(2, (i) => i == index);
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "Applied Jobs",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "Saved Jobs",
                            style: TextStyle(
                              fontSize: 14,
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

                // 🧠 decide which list to show
                if (isSelected[0]) {
                  // ---- Applied Jobs ----
                  return Expanded(
                    child: ref
                        .watch(getUserApplicationsProvider)
                        .when(
                          data:
                              (apps) =>
                                  apps.isEmpty
                                      ? const Center(
                                        child: Text("No Job Applied"),
                                      )
                                      : ListView.builder(
                                        itemCount: apps.length,
                                        itemBuilder:
                                            (_, i) => AppliedJobsCard(
                                              jobApplicationDetails: apps[i],
                                            ),
                                      ),
                          error:
                              (_, __) => const Center(
                                child: Text("Error loading your applications"),
                              ),
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        ),
                  );
                } else{
                  // ---- Saved Jobs ----
                  return Expanded(
                    child: ref
                        .watch(getAllSavedJobsProvider)
                        .when(
                          data:
                              (jobs) =>
                                  jobs.isEmpty
                                      ? const Center(
                                        child: Text("No Saved Jobs"),
                                      )
                                      : ListView.builder(
                                        itemCount: jobs.length,
                                        itemBuilder:
                                            (_, i) => SavedJobsListWidget(
                                              job: jobs[i],
                                            ),
                                      ),
                          error: (e, __) => Center(child: Text('Error: $e')),
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        ),
                  );
                } 
              },
            ),
          ],
        ),
      ),
    );
  }
}
