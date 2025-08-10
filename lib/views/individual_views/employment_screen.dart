import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/employment_history_card.dart';
import 'package:swamper_solution/views/custom_widgets/job_offers_card.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class EmploymentScreen extends StatelessWidget {
  const EmploymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

    String formatPostedDate(String raw) {
      final dt = DateTime.parse(raw); // 2025‑07‑13 12:51:38.960000
      return dateFormat.format(dt);
    }

    final rangeFormat = DateFormat('d/M/yyyy'); // 14/7/2025

    int calcNumberOfDays(String range) {
      final parts = range.split(' to ');
      if (parts.length != 2) return 0; // fallback
      final start = rangeFormat.parse(parts[0]);
      final end = rangeFormat.parse(parts[1]);
      return end.difference(start).inDays + 1; // inclusive
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Employment History", 
          style: CustomTextStyles.title.copyWith(color: Colors.black87)
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
                    final isSelected = ref.watch(employmentProvider);

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
                              .read(employmentProvider.notifier)
                              .state = List.generate(2, (i) => i == index);
                        },
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Job History",
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
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Job Offers",
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
                    final isSelected = ref.watch(employmentProvider);
                    final offersAsync = ref.watch(getJobOffersProvider);
                    final userAsync = ref.watch(individualProvider);
                    final jobHistoryAsync = ref.watch(getJobHistoryProvider);

                    if (isSelected[0]) {
                      // ── JOB HISTORY ──────────────────────────────────────────────
                      return jobHistoryAsync.when(
                        data: (history) {
                          if (history.isEmpty) {
                            return _buildEmptyState(
                              icon: Icons.history,
                              title: "No Job History",
                              subtitle: "Your completed jobs will appear here once you finish them",
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.only(top: 16, bottom: 100),
                            itemCount: history.length,
                            itemBuilder: (_, i) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: EmploymentHistoryCard(
                                  title: history[i].role,
                                  location: history[i].location,
                                  startedDate: formatPostedDate(
                                    history[i].postedDate,
                                  ),
                                  hourlyIncome: history[i].hourlyIncome.toString(),
                                  noOfDays: calcNumberOfDays(history[i].days).toString(),
                                ),
                              );
                            },
                          );
                        },
                        error: (error, stack) {
                          return _buildErrorState("Error fetching job history: $error");
                        },
                        loading: () {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          );
                        },
                      );
                    }

                    return offersAsync.when(
                      data: (offers) {
                        return userAsync.when(
                          data: (user) {
                            if (offers.isEmpty) {
                              return _buildEmptyState(
                                icon: Icons.local_offer_outlined,
                                title: "No Job Offers",
                                subtitle: "Job offers from employers will appear here",
                              );
                            }
                            return ListView.builder(
                              padding: EdgeInsets.only(top: 16, bottom: 100),
                              itemCount: offers.length,
                              itemBuilder: (_, i) => Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: JobOffersCard(
                                  jobDetails: offers[i],
                                  userDetails: user!,
                                ),
                              ),
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          error: (e, __) => _buildErrorState("User load error: $e"),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      error: (error, __) => _buildErrorState("Error while loading offers: $error"),
                    );
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
              child: Icon(
                icon,
                size: 48,
                color: Colors.blue[300],
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: CustomTextStyles.title.copyWith(
                color: Colors.grey[800],
              ),
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
              style: CustomTextStyles.title.copyWith(
                color: Colors.grey[800],
              ),
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
