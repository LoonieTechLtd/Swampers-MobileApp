import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/core/services/auth_services.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_drop_down.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';

class GoogleIndividualForm extends StatefulWidget {
  final String uid;
  final String email;
  const GoogleIndividualForm({
    super.key,
    required this.uid,
    required this.email,
  });

  @override
  State<GoogleIndividualForm> createState() => _GoogleIndividualFormState();
}

class _GoogleIndividualFormState extends State<GoogleIndividualForm> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final List<String> workOptions = [
    "Warehouse Associates",
    "Lumping & Destuffing",
    "Constructions",
    "Factory Works",
    "Handy Man",
    "Cleaning",
    "Movers",
    "General Works",
    "Restaurant Service",
  ];

  bool isLoading = false;
  String? selectedWork;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Form(
              key: formKey,
              child: Column(
                spacing: 10,
                children: [
                  Image.asset(
                    "assets/images/company_logo.png",
                    height: 180,
                    width: 180,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Complete Your Profile",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: CustomTextfield(
                          hintText: "First name",
                          controller: firstNameController,
                          obscureText: false,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "First name cannot be empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        child: CustomTextfield(
                          hintText: "Last name",
                          controller: lastNameController,
                          obscureText: false,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Last name cannot be empty";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  CustomTextfield(
                    hintText: "Contact no",
                    controller: phoneController,
                    obscureText: false,
                    textInputType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Phone cannot be empty";
                      }
                      if (value.length < 10) {
                        return "Phone must be at least 10 digits";
                      }
                      return null;
                    },
                  ),
                  CustomTextfield(
                    hintText: "Address",
                    controller: addressController,
                    obscureText: false,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Address cannot be empty";
                      }
                      return null;
                    },
                  ),

                  // Work options drop Down
                  CustomDropDown(
                    value: selectedWork,
                    hintText: "Select your interested work",
                    options: workOptions,
                    onChanged: (value) {
                      setState(() {
                        selectedWork = value;
                      });
                    },
                  ),

                  const SizedBox(height: 40),
                  CustomButton(
                    backgroundColor: Colors.blue,
                    isLoading: isLoading,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        final result = await AuthServices()
                            .completeGoogleUserProfile(
                              uid: widget.uid,
                              email: widget.email,
                              firstName: firstNameController.text,
                              lastName: lastNameController.text,
                              phone: phoneController.text,
                              address: addressController.text,
                              interestedWork: selectedWork,
                              type: "Individual",
                            );
                        if (result == "Success") {
                          if (!mounted) return;
                          context.go('/individual');
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
                    text: "Complete Registration",
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
