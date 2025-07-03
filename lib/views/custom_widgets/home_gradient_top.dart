import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/custom_search_bar.dart';
import 'package:swamper_solution/views/custom_widgets/stat_widget.dart';

class HomeGradientTop extends StatelessWidget {
  HomeGradientTop({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color.fromARGB(255, 5, 100, 178),
            const Color.fromARGB(255, 5, 100, 178),
            const Color.fromARGB(255, 28, 28, 30),
          ],
        ),
      ),
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final userAsync = ref.read(individualProvider);
              return userAsync.when(
                data: (user) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 12),
                      CircleAvatar(
                        backgroundImage: NetworkImage(user!.profilePic),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            user.firstName,
                            style: CustomTextStyles.h5.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Welcome back",
                            style: CustomTextStyles.description.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(FeatherIcons.bell, color: Colors.white),
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
          CustomSearchBar(searchController: searchController, hintText: "Search Job Roles",),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              StatWidget(data: "340", label: "Total Hours"),
              StatWidget(data: "23", label: "Total Jobs"),
              StatWidget(data: "8k+", label: "Total Earning"),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
