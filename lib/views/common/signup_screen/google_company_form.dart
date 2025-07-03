import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/services/auth_services.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';

class GoogleCompanyForm extends StatefulWidget {
  final String uid;
  final String email;
  const GoogleCompanyForm({super.key, required this.uid, required this.email});

  @override
  State<GoogleCompanyForm> createState() => _GoogleCompanyFormState();
}

class _GoogleCompanyFormState extends State<GoogleCompanyForm> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    companyNameController.dispose();
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
                    "Complete Company Profile",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  CustomTextfield(
                    hintText: "Company Name",
                    controller: companyNameController,
                    obscureText: false,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Company Name cannot be empty";
                      }
                      return null;
                    },
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
                  const SizedBox(height: 30),
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
                              companyName: companyNameController.text,
                              phone: phoneController.text,
                              address: addressController.text,
                              type: "Company",
                            );
                        if (result == "Success") {
                          if (!mounted) return;
                          context.go('/company');
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
