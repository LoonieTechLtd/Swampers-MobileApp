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
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

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
      appBar: AppBar(
        centerTitle: true,
        title: Text("Employent History", style: CustomTextStyles.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Consumer(
                builder: (context, ref, child) {
                  final isSelected = ref.watch(employmentProvider);

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
                            .read(employmentProvider.notifier)
                            .state = List.generate(2, (i) => i == index);
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "Job History",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "Job Offers",
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
                final isSelected = ref.watch(employmentProvider);
                final offersAsync = ref.watch(getJobOffersProvider);
                final userAsync = ref.watch(individualProvider);
                final jobHistoryAsync = ref.watch(getJobHistoryProvider);
                if (isSelected[0]) {
                  // ── JOB HISTORY ──────────────────────────────────────────────
                  return Expanded(
                    child: jobHistoryAsync.when(
                      data: (history) {
                        if (history.isEmpty) {
                          return Center(child: Text("No Job History"));
                        }
                        debugPrint(history.map((e) => e.toMap()).toString());
                        return ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (_, i) {
                            return EmploymentHistoryCard(
                              title: history[i].role,
                              location: history[i].location,
                              startedDate: formatPostedDate(
                                history[i].postedDate,
                              ),
                              hourlyIncome: history[i].hourlyIncome.toString(),
                              noOfDays:
                                  calcNumberOfDays(history[i].days).toString(),
                            );
                          },
                        );
                      },
                      error: (error, stack) {
                        return Center(
                          child: Text("Error fetching job history: $error"),
                        );
                      },
                      loading: () {
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  );
                }

                return Expanded(
                  child: offersAsync.when(
                    data: (offers) {
                      return userAsync.when(
                        data: (user) {
                          if (offers.isEmpty) {
                            return const Center(child: Text("No job Offers"));
                          }
                          return ListView.builder(
                            itemCount: offers.length,
                            itemBuilder:
                                (_, i) => JobOffersCard(
                                  jobDetails: offers[i],
                                  userDetails: user!,
                                ),
                          );
                        },
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (e, __) =>
                                Center(child: Text("User load error: $e")),
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, __) => Center(
                          child: Text("Error while loading offers: $error"),
                        ),
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
