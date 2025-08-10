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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "My Applications",
          style: CustomTextStyles.title.copyWith(color: Colors.black87),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced header section with gradient background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Consumer(
                  builder: (context, ref, child) {
                    final isSelected = ref.watch(applicationProvider);

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ToggleButtons(
                        isSelected: isSelected,
                        borderRadius: BorderRadius.circular(25),
                        selectedColor: Colors.white,
                        fillColor: Colors.blue[600],
                        color: Colors.grey[600],
                        borderColor: Colors.transparent,
                        selectedBorderColor: Colors.transparent,
                        splashColor: Colors.blue[100],
                        highlightColor: Colors.blue[50],
                        constraints: BoxConstraints(
                          minHeight: 50.0,
                          minWidth: MediaQuery.of(context).size.width * 0.42,
                        ),
                        onPressed: (int index) {
                          ref
                              .read(applicationProvider.notifier)
                              .state = List.generate(2, (i) => i == index);
                        },
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.work_outline, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Applied Jobs",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bookmark_outline, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Saved Jobs",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Enhanced content section with padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer(
                  builder: (context, ref, child) {
                    final isSelected = ref.watch(applicationProvider);

                    // 🧠 decide which list to show
                    if (isSelected[0]) {
                      // ---- Applied Jobs ----
                      return ref
                          .watch(getUserApplicationsProvider)
                          .when(
                            data:
                                (apps) =>
                                    apps.isEmpty
                                        ? _buildEmptyState(
                                          icon: Icons.work_outline,
                                          title: "No Applications Yet",
                                          subtitle:
                                              "Start applying to jobs and track your progress here",
                                        )
                                        : ListView.builder(
                                          padding: EdgeInsets.only(
                                            top: 16,
                                            bottom: 100,
                                          ),
                                          itemCount: apps.length,
                                          itemBuilder:
                                              (_, i) => Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: AppliedJobsCard(
                                                  jobApplicationDetails:
                                                      apps[i],
                                                ),
                                              ),
                                        ),
                            error:
                                (_, __) => _buildErrorState(
                                  "Error loading your applications",
                                ),
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue,
                                    ),
                                  ),
                                ),
                          );
                    } else {
                      // ---- Saved Jobs ----
                      return ref
                          .watch(getAllSavedJobsProvider)
                          .when(
                            data:
                                (jobs) =>
                                    jobs.isEmpty
                                        ? _buildEmptyState(
                                          icon: Icons.bookmark_outline,
                                          title: "No Saved Jobs",
                                          subtitle:
                                              "Save interesting jobs to access them quickly later",
                                        )
                                        : ListView.builder(
                                          padding: EdgeInsets.only(
                                            top: 16,
                                            bottom: 100,
                                          ),
                                          itemCount: jobs.length,
                                          itemBuilder:
                                              (_, i) => Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: SavedJobsListWidget(
                                                  job: jobs[i],
                                                ),
                                              ),
                                        ),
                            error: (e, __) => _buildErrorState('Error: $e'),
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue,
                                    ),
                                  ),
                                ),
                          );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.blue[300]),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: CustomTextStyles.title.copyWith(color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: CustomTextStyles.bodyText.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[300],
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Oops! Something went wrong",
              style: CustomTextStyles.title.copyWith(color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: CustomTextStyles.bodyText.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
