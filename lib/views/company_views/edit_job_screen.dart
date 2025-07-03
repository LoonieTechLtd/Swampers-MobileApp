import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_controller.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';

class EditJobScreen extends StatefulWidget {
  final JobModel jobDetails;
  const EditJobScreen({super.key, required this.jobDetails});
  @override
  EditJobScreenState createState() => EditJobScreenState();
}

class EditJobScreenState extends State<EditJobScreen> {
  final TextEditingController _roleTypeController = TextEditingController();
  final TextEditingController _workersController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String companyId = FirebaseAuth.instance.currentUser!.uid.toString();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _timeRanges = [];

  void clearForm() {
    _roleTypeController.clear();
    _workersController.clear();
    _incomeController.clear();
    _shiftController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _timeRanges.clear();
  }

  @override
  void dispose() {
    _roleTypeController.dispose();
    _workersController.dispose();
    _incomeController.dispose();
    _shiftController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to show the time range picker dialog
  Future<void> _selectTimeRanges(BuildContext context) async {
    bool addMore = true;
    List<String> tempTimeRanges = [..._timeRanges];

    while (addMore) {
      TimeOfDay? startTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (startTime != null && endTime != null) {
        String timeRange =
            '${startTime.format(context)} To ${endTime.format(context)}';
        tempTimeRanges.add(timeRange);

        addMore =
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Add another time range?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
            ) ??
            false;
      } else {
        addMore = false; // Exit loop if either time is null
      }
    }
    setState(() {
      _timeRanges = tempTimeRanges;
      _shiftController.text = _timeRanges.join(', ');
    });
  }

  @override
  void initState() {
    _roleTypeController.text = widget.jobDetails.role;
    _workersController.text = widget.jobDetails.noOfWorkers.toString();
    _incomeController.text = widget.jobDetails.hourlyIncome.toString();
    _shiftController.text = widget.jobDetails.shifts.join(', ');
    _locationController.text = widget.jobDetails.location;
    _descriptionController.text = widget.jobDetails.description;
    _timeRanges = widget.jobDetails.shifts;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Post a Job"),
      ),
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
                  JobDetailsField(
                    controller: _workersController,
                    title: "No of Workers",
                    hintText: "2, 4, 20",
                    inputType: TextInputType.numberWithOptions(),
                  ),
                  JobDetailsField(
                    controller: _incomeController,
                    title: "Hourly income",
                    hintText: "40\$ / hr",
                    inputType: TextInputType.number,
                  ),

                  // Time Ranges 
                  InkWell(
                    onTap: () => _selectTimeRanges(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Shifts", style: CustomTextStyles.h5),
                        Container(
                          padding: EdgeInsets.only(left: 12),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black12,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child:
                                _timeRanges.isEmpty
                                    ? Text(
                                      "01:30 To 05:30",
                                      style: CustomTextStyles.description
                                          .copyWith(color: Colors.black38),
                                    )
                                    : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(
                                          _timeRanges.length,
                                          (index) {
                                            return Container(
                                              margin: EdgeInsets.only(right: 8),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(_timeRanges[index]),
                                                  SizedBox(width: 4),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _timeRanges.removeAt(
                                                          index,
                                                        );
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.cancel_outlined,
                                                      size: 18,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  JobDetailsField(
                    controller: _locationController,
                    title: "City/Location",
                    hintText: "Melborn",
                  ),
                  JobDescriptionField(
                    descriptionController: _descriptionController,
                  ),
                  CustomButton(
                    backgroundColor: Colors.blue,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final JobModel updatedJob = JobModel(
                        jobId: widget.jobDetails.jobId,
                        role: _roleTypeController.text,
                        noOfWorkers: int.parse(_workersController.text),
                        shifts: _shiftController.text.split(", "),
                        location: _locationController.text,
                        description: _descriptionController.text,
                        images: widget.jobDetails.images,
                        postedDate: widget.jobDetails.postedDate,
                        companyId: companyId,
                        hourlyIncome: double.parse(_incomeController.text),
                        jobStatus: widget.jobDetails.jobStatus,
                      );
                      final isSuccess = await JobController().updateJob(
                        updatedJob,
                        widget.jobDetails.jobId,
                      );
                      if (isSuccess) {
                        showCustomSnackBar(
                          context: context,
                          message: "Job Updated Successfully",
                          backgroundColor: Colors.green,
                        );
                      } else {
                        showCustomSnackBar(
                          context: context,
                          message: "Failed to Update Job",
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                    text: "Save this job",
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

class JobDescriptionField extends StatelessWidget {
  final TextEditingController descriptionController;

  const JobDescriptionField({super.key, required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description, Notes", style: CustomTextStyles.h5),
        SizedBox(
          height: 100,
          child: TextFormField(
            controller: descriptionController,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            maxLines: null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(width: 1, color: Colors.black38),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class JobDetailsField extends StatelessWidget {
  const JobDetailsField({
    super.key,
    required this.controller,
    required this.title,
    required this.hintText,
    this.inputType,
    this.enabled = true, // Added enabled parameter
    this.onTap, // Added onTap parameter
    this.maxLines,
  });

  final TextEditingController controller;
  final String title;
  final String hintText;
  final TextInputType? inputType;
  final bool enabled;
  final VoidCallback? onTap;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CustomTextStyles.h5),
        GestureDetector(
          onTap: onTap,
          child: CustomTextfield(
            hintText: hintText,
            controller: controller,
            obscureText: false,
            textInputType: inputType ?? TextInputType.text,
            enabled: enabled,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "This cannot be empty";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
