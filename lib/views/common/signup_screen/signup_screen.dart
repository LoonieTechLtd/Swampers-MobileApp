import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/auth_navigation_button.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';
import 'package:swamper_solution/views/common/signup_screen/individual_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final isSelected = ref.watch(roleProvider);
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
                          ref.read(roleProvider.notifier).state = newSelection;
                        },
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              "Company",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              "Individual",
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
                Image.asset(
                  "assets/images/company_logo.png",
                  height: 180,
                  width: 180,
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final isSelected = ref.watch(roleProvider);
                    return Center(
                      child:
                          isSelected[0] == true
                              ? CompanyForm(ref: ref)
                              : IndividualForm(ref: ref),
                    );
                  },
                ),
                SizedBox(height: 40),
                AuthNavigationButton(
                  prefixText: "Already have an account?",
                  buttonText: "Login.",
                  onTap: () async{
                    await FirebaseAuth.instance.signOut();
                    context.push('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
