import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_controller.dart';
import 'package:swamper_solution/models/company_model.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/day_range_selector.dart';
import 'package:swamper_solution/views/custom_widgets/job_description_field.dart';
import 'package:swamper_solution/views/custom_widgets/job_details_field.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';
import 'package:swamper_solution/views/custom_widgets/time_range_selector.dart';

class JobPostingScreen extends StatefulWidget {
  final String jobRole;
  final CompanyModel companyData;
  const JobPostingScreen({
    super.key,
    required this.jobRole,
    required this.companyData,
  });
  @override
  JobPostingScreenState createState() => JobPostingScreenState();
}

class JobPostingScreenState extends State<JobPostingScreen> {
  final TextEditingController _roleTypeController = TextEditingController();
  final TextEditingController _workersController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _messageToAdminController =
      TextEditingController();
  final String companyId = FirebaseAuth.instance.currentUser!.uid.toString();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _timeRanges = [];
  List<XFile> _selectedImages = [];
  List<String> shifts = [];
  DateTimeRange? selectedDayRange;
  String? dayRangeStr;

  void clearForm() {
    _roleTypeController.clear();
    _workersController.clear();
    _incomeController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _timeRanges.clear();
    _messageToAdminController.clear();
  }

  @override
  void dispose() {
    _roleTypeController.dispose();
    _workersController.dispose();
    _incomeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _messageToAdminController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // pick a number of days
  Future<void> selectDayRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: selectedDayRange,
    );
    if (picked != null) {
      setState(() {
        selectedDayRange = picked;

        dayRangeStr =
            "${formatDate(picked.start)} to ${formatDate(picked.end)}";
      });
    }
  }

  @override
  void initState() {
    _roleTypeController.text = widget.jobRole;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Post a Job")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                spacing: 12,
                children: [
                  JobDetailsField(
                    enabled: false,
                    controller: _roleTypeController,
                    title: "Role Type",
                    hintText: "Helper",
                  ),

                  // select images section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Site Images (max 4)", style: CustomTextStyles.h5),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ..._selectedImages.map(
                            (img) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.file(
                                    File(img.path),
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.remove(img);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedImages.length < 4)
                            GestureDetector(
                              onTap: () async {
                                final ImagePicker picker = ImagePicker();
                                final List<XFile> pickedFiles =
                                    await picker.pickMultiImage();
                                setState(() {
                                  // Limit to 4 images
                                  _selectedImages =
                                      [
                                        ..._selectedImages,
                                        ...pickedFiles,
                                      ].take(4).toList();
                                });
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 30,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (_selectedImages.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "No images selected.",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  JobDetailsField(
                    controller: _workersController,
                    title: "No of Workers",
                    hintText: "10, 20",
                    inputType: TextInputType.numberWithOptions(),
                  ),

                  JobDetailsField(
                    controller: _incomeController,
                    title: "Hourly income",
                    hintText: "40\$ / hr",
                    inputType: TextInputType.number,
                    validator: (value) {
                      if (int.parse(value!) < 30) {
                        return "The amount cannot be less then 30";
                      }
                      if (int.parse(value) > 50) {
                        return "The amount cannot be more then 50";
                      }
                      return null;
                    },
                  ),

                  // Date range selector
                  DayRangeSelector(
                    selectedDayRange: selectedDayRange,
                    dayRangeStr: dayRangeStr,
                    onTap: () {
                      selectDayRange(context);
                    },
                    onClear: () {
                      setState(() {
                        selectedDayRange = null;
                        dayRangeStr = null;
                      });
                    },
                  ),

                  // Shifts selector
                  TimeRangeSelector(
                    timeRanges: _timeRanges,
                    onRangesUpdated: (updatedRanges) {
                      setState(() {
                        _timeRanges = updatedRanges;
                      });
                    },
                  ),
                  JobDetailsField(
                    controller: _locationController,
                    title: "City/Location",
                    hintText: "Melborn",
                  ),
                  JobDescriptionField(
                    title: "Job Description",
                    textEditingController: _descriptionController,
                  ),
                  JobDescriptionField(
                    hintText: "Reassign jobs to: Joe Doe, Figo Carlos",
                    title: "Message to admin",
                    textEditingController: _messageToAdminController,
                  ),
                  CustomButton(
                    backgroundColor: Colors.blue,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => Dialog(
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(width: 20),
                                    const Text('Job is being posted...'),
                                  ],
                                ),
                              ),
                            ),
                      );
                      // Add this line to let the dialog render
                      await Future.delayed(Duration.zero);
                      final jobId = randomAlphaNumeric(6);
                      List<String> imageUrls = [];
                      if (_selectedImages.isNotEmpty) {
                        imageUrls = await JobController().uploadImages(
                          _selectedImages,
                        );
                        if (imageUrls.isEmpty) {
                          Navigator.of(context, rootNavigator: true).pop();
                          showCustomSnackBar(
                            context: context,
                            message:
                                "Failed to upload images. Please try again.",
                            backgroundColor: Colors.red,
                          );
                          return;
                        }
                      }
                      debugPrint(
                        'Image URLs to be saved: ${imageUrls.toString()}',
                      );

                      final JobModel newJob = JobModel(
                        role: _roleTypeController.text,
                        noOfWorkers: int.parse(_workersController.text),
                        shifts: _timeRanges,
                        location: _locationController.text,
                        description: _descriptionController.text,
                        images: imageUrls,
                        hourlyIncome: double.parse(_incomeController.text),
                        postedDate: DateTime.now().toString(),
                        companyId: companyId,
                        jobId: jobId,
                        jobStatus: "Pending",
                        days: dayRangeStr ?? '',
                        messageToAdmin: _messageToAdminController.text,
                        assignedStaffs: [],
                      );

                      final message = await JobController().postJob(
                        newJob,
                        jobId,
                      );

                      Navigator.of(context, rootNavigator: true).pop();

                      if (message == null) {
                        clearForm();
                        showCustomSnackBar(
                          context: context,
                          message: "Job Posted Successfully",
                          backgroundColor: Colors.green,
                        );
                        context.pop();
                      } else {
                        showCustomSnackBar(
                          context: context,
                          message: "Failed to post new Job",
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                    text: "Post This Job",
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
