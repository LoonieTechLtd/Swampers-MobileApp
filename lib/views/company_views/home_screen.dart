import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/jobs_template_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_search_bar.dart';
import 'package:swamper_solution/views/custom_widgets/stat_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final List<JobsTemplateModel> jobTemplates = [
      JobsTemplateModel(
        jobId: "JOB1",
        roleName: "Warehouse Associates",
        prefixImage: "https://i.imgur.com/qlueg7Q.png",
      ),
       JobsTemplateModel(
        jobId: "JOB2",
        roleName: "Lumping & Destuffing",
        prefixImage: "https://i.imgur.com/LYiQxJI.png",
      ),
      JobsTemplateModel(
        jobId: "JOB3",
        roleName: "Construction Labours",
        prefixImage: "https://i.imgur.com/jg1eToy.png",
      ),
      JobsTemplateModel(
        jobId: "JOB4",
        roleName: "Factory Workers",
        prefixImage: "https://i.imgur.com/O49gppV.png",
      ),
      JobsTemplateModel(
        jobId: "JOB5",
        roleName: "Handy Man",
        prefixImage: "https://i.imgur.com/xDGeNur.png",
      ),
      JobsTemplateModel(
        jobId: "JOB6",
        roleName: "Cleaners",
        prefixImage: "https://i.imgur.com/WjAWFr7.png",
      ),
      JobsTemplateModel(
        jobId: "JOB7",
        roleName: "Mover",
        prefixImage: "https://i.imgur.com/cN5TZ3M.png",
      ),
      JobsTemplateModel(
        jobId: "JOB8",
        roleName: "General Workers",
        prefixImage: "https://i.imgur.com/h1CcThv.png",
      ),
      JobsTemplateModel(
        jobId: "JOB9",
        roleName: "Restaurent Services",
        prefixImage: "https://i.imgur.com/VGvA0Pe.png",
      ),
    ];
    return Scaffold(
      body: SafeArea(
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
                            return const Center(child: Text('No user data'));
                          }
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 12),
                              CircleAvatar(
                                backgroundImage: NetworkImage(user.profilePic),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

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
                                   context.go('/company/company_notifications');
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
                          return Text("Error lodaing user data");
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StatWidget(
                                data: data.totalHired.toString(),
                                label: "Total Hired",
                              ),
                              StatWidget(
                                data: data.totalJobs.toString(),
                                label: "Total Jobs",
                              ),
                              StatWidget(
                                data: data.totalPay.toString(),
                                label: "Total Pay",
                              ),
                            ],
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
                  SizedBox(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final user = ref.watch(companyProvider);
                return user.when(
                  data: (user) {
                    if (user == null) {
                      return Center(child: Text("No user Data"));
                    }
                    return Column(
                      children: [
                        ...List.generate(
                          jobTemplates.length,
                          (index) => InkWell(
                            onTap: () {
                              context.goNamed(
                                "job_posting_screen",
                                pathParameters: {
                                  'job_role': jobTemplates[index].roleName,
                                },
                                extra: user,
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 2,
                                  ),
                                  height: 80,
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.09,
                                        width:
                                            MediaQuery.of(context).size.height *
                                            0.09,
                                        child: Image(
                                          image: CachedNetworkImageProvider(
                                            jobTemplates[index].prefixImage,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        jobTemplates[index].roleName,
                                        style: CustomTextStyles.h4,
                                      ),
                                      Spacer(),
                                      CircleAvatar(
                                        backgroundColor:
                                            AppColors().primaryColor,
                                        child: Icon(
                                          FeatherIcons.chevronRight,
                                          color: AppColors().white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                        ),
                      ],
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
      ),
    );
  }
}
