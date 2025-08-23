import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_template_controller.dart';
import 'package:swamper_solution/models/jobs_template_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_search_bar.dart';
import 'package:swamper_solution/views/custom_widgets/stat_widget.dart';

// Job Template Provider
final jobTemplateProvider = FutureProvider<List<JobsTemplateModel>>((ref) {
  return JobTemplateController().fetchJobTemplates();
});

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper method to validate URL
  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(companyProvider);
                ref.invalidate(getCompanyStats);
                ref.invalidate(jobTemplateProvider);
              },
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors().primaryColor,
                          AppColors().primaryColor,
                          AppColors().turnaryColor,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final userAsync = ref.watch(companyProvider);
                            return userAsync.when(
                              data: (user) {
                                if (user == null) {
                                  return const Center(
                                    child: Text('No user data'),
                                  );
                                }
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 12),
                                    CircleAvatar(
                                      backgroundImage:
                                          _isValidUrl(user.profilePic)
                                              ? NetworkImage(user.profilePic)
                                              : null,
                                      child:
                                          _isValidUrl(user.profilePic)
                                              ? null
                                              : Icon(
                                                FeatherIcons.user,
                                                color: AppColors().white,
                                              ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.companyName,
                                          style: CustomTextStyles.h5.copyWith(
                                            color: AppColors().white,
                                          ),
                                        ),
                                        Text(
                                          "Welcome back",
                                          style: CustomTextStyles.description
                                              .copyWith(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        context.go(
                                          '/company/company_notifications',
                                        );
                                      },
                                      icon: Icon(
                                        FeatherIcons.bell,
                                        color: AppColors().white,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              error: (error, stack) {
                                return Text("Error loading user data");
                              },
                              loading: () {
                                return Center(child: SizedBox());
                              },
                            );
                          },
                        ),
                        CustomSearchBar(
                          searchController: searchController,
                          hintText: "Search Job Topics",
                        ),
                        const SizedBox(height: 16),
                        Consumer(
                          builder: (context, ref, child) {
                            final userStats = ref.watch(getCompanyStats);
                            return userStats.when(
                              data: (data) {
                                if (data == null) {
                                  return Center(
                                    child: Text("No stats data available"),
                                  );
                                }
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    StatWidget(
                                      data: data.totalHired.toString(),
                                      label: "Total Hired",
                                    ),
                                    StatWidget(
                                      data: data.totalJobs.toString(),
                                      label: "Total Jobs",
                                    ),
                                  ],
                                );
                              },
                              error: (error, stack) {
                                return Center(child: Text("Error: $error"));
                              },
                              loading: () {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final userAsync = ref.watch(companyProvider);
                      final jobTemplatesAsync = ref.watch(jobTemplateProvider);

                      return userAsync.when(
                        data: (user) {
                          if (user == null) {
                            return Center(child: Text("No user data"));
                          }

                          return jobTemplatesAsync.when(
                            data: (jobs) {
                              if (jobs.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          FeatherIcons.briefcase,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No job templates yet',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: jobs.length,
                                itemBuilder: (context, index) {
                                  final job = jobs[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 3.0,
                                    ),
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () {
                                          context.goNamed(
                                            "job_posting_screen",
                                            pathParameters: {
                                              'job_role': job.roleName,
                                            },
                                            extra: user,
                                          );
                                        },
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          leading:
                                              _isValidUrl(job.prefixImage)
                                                  ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      errorWidget: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors
                                                                    .grey[300],
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Icon(
                                                            FeatherIcons
                                                                .briefcase,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                          ),
                                                        );
                                                      }, imageUrl: job.prefixImage,
                                                    ),
                                                  )
                                                  : Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      FeatherIcons.briefcase,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                          title: Text(
                                            job.roleName,
                                            style: CustomTextStyles.h4.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Tap to post jobs",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                          trailing: Container(
                                            height: 36,
                                            width: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors().primaryColor
                                                  
                                            ),
                                            child: Icon(
                                              FeatherIcons.chevronRight,
                                              color: AppColors().white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            error: (error, stack) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        FeatherIcons.alertCircle,
                                        size: 64,
                                        color: Colors.red,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Error loading job templates',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '$error',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          ref.invalidate(jobTemplateProvider);
                                        },
                                        child: Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loading: () {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
