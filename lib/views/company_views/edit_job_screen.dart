import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/job_controller.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';
import 'package:swamper_solution/views/custom_widgets/job_description_field.dart';
import 'package:swamper_solution/views/custom_widgets/time_range_dialog.dart';

class EditJobScreen extends StatefulWidget {
  final JobModel jobDetails;
  const EditJobScreen({super.key, required this.jobDetails});

  @override
  EditJobScreenState createState() => EditJobScreenState();
}

class EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _roleTypeController = TextEditingController();
  final _workersController = TextEditingController();
  final _incomeController = TextEditingController();
  final _shiftController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _messageToAdminController = TextEditingController();

  final String companyId = FirebaseAuth.instance.currentUser!.uid;

  List<String> _timeRanges = [];
  DateTimeRange? selectedDayRange;
  String? dayRangeStr;

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
    final job = widget.jobDetails;
    _roleTypeController.text = job.role;
    _workersController.text = job.noOfWorkers.toString();
    _incomeController.text = job.hourlyIncome.toString();
    _shiftController.text = job.shifts.join(', ');
    _locationController.text = job.location;
    _descriptionController.text = job.description;
    _timeRanges = job.shifts;
    dayRangeStr = job.days;
    _messageToAdminController.text = job.messageToAdmin ?? "";
  }

  Future<void> _selectTimeRanges(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (_) => TimeRangeDialog(
            initialTimeRanges: List.from(_timeRanges),
            onTimeRangesSelected: (selectedRanges) {
              setState(() {
                _timeRanges = selectedRanges;
                _shiftController.text = selectedRanges.join(', ');
              });
            },
          ),
    );
  }

  Future<void> _selectDayRange(BuildContext context) async {
    final parts = widget.jobDetails.days.split(" to ");
    if (parts.length != 2) return;

    DateTime start = _parseDate(parts[0]);
    DateTime end = _parseDate(parts[1]);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange:
          selectedDayRange ?? DateTimeRange(start: start, end: end),
    );

    if (picked != null) {
      setState(() {
        selectedDayRange = picked;
        dayRangeStr =
            "${_formatDate(picked.start)} to ${_formatDate(picked.end)}";
      });
    }
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedJob = JobModel(
      jobId: widget.jobDetails.jobId,
      role: _roleTypeController.text,
      noOfWorkers: int.parse(_workersController.text),
      shifts: _timeRanges,
      location: _locationController.text,
      description: _descriptionController.text,
      images: widget.jobDetails.images,
      postedDate: widget.jobDetails.postedDate,
      companyId: companyId,
      hourlyIncome: double.parse(_incomeController.text),
      jobStatus: widget.jobDetails.jobStatus,
      days: dayRangeStr ?? widget.jobDetails.days,
      messageToAdmin:  _messageToAdminController.text,
      assignedStaffs: []
    );

    final isSuccess = await JobController().updateJob(
      updatedJob,
      widget.jobDetails.jobId,
    );
    showCustomSnackBar(
      context: context,
      message: isSuccess ? "Job Updated Successfully" : "Failed to Update Job",
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Edit Job")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                spacing: 6,
                children: [
                  _buildJobField(
                    _roleTypeController,
                    "Role Type",
                    "Helper",
                    enabled: false,
                  ),
                  _buildJobField(
                    _workersController,
                    "No of Workers",
                    "2, 4, 20",
                    inputType: TextInputType.number,
                  ),
                  _buildJobField(
                    _incomeController,
                    "Hourly income",
                    "40\$ / hr",
                    inputType: TextInputType.number,
                  ),
                  _buildDatePickerField(context),
                  _buildShiftPickerField(context),
                  _buildJobField(
                    _locationController,
                    "City/Location",
                    "Melborn",
                  ),
                  JobDescriptionField(
                    textEditingController: _descriptionController,
                    title: 'Job Description',
                  ),
                  JobDescriptionField(
                    textEditingController: _messageToAdminController,
                    title: 'Message to Admin',
                    hintText: "Reassign jobs to: Joe Doe, Figo Carlos",
                  ),
                  CustomButton(
                    backgroundColor: Colors.blue,
                    onPressed: _onSave,
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

  Widget _buildJobField(
    TextEditingController controller,
    String title,
    String hintText, {
    TextInputType? inputType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CustomTextStyles.h5),
        CustomTextfield(
          hintText: hintText,
          controller: controller,
          obscureText: false,
          textInputType: inputType ?? TextInputType.text,
          enabled: enabled,
          validator:
              (value) =>
                  value == null || value.trim().isEmpty
                      ? "This cannot be empty"
                      : null,
        ),
      ],
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDayRange(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Days", style: CustomTextStyles.h5),
          Container(
            padding: const EdgeInsets.only(left: 12),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black12,
            ),
            alignment: Alignment.centerLeft,
            child:
                dayRangeStr == null
                    ? Text(
                      "Jan 2 to Feb 14",
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.black38,
                      ),
                    )
                    : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueGrey),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(dayRangeStr!),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dayRangeStr = null;
                                selectedDayRange = null;
                              });
                            },
                            child: const Icon(
                              Icons.cancel_outlined,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftPickerField(BuildContext context) {
    return InkWell(
      onTap: () => _selectTimeRanges(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Shifts", style: CustomTextStyles.h5),
          Container(
            padding: const EdgeInsets.only(left: 12),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black12,
            ),
            alignment: Alignment.centerLeft,
            child:
                _timeRanges.isEmpty
                    ? Text(
                      "01:30 To 05:30",
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.black38,
                      ),
                    )
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            _timeRanges.map((time) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blueGrey),
                                ),
                                child: Row(
                                  children: [
                                    Text(time),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _timeRanges.remove(time);
                                          _shiftController.text = _timeRanges
                                              .join(", ");
                                        });
                                      },
                                      child: const Icon(
                                        Icons.cancel_outlined,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
