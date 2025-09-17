import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/kyc_controller.dart';
import 'package:swamper_solution/core/helpers/file_picker_helper.dart';
import 'package:swamper_solution/models/crimers_model.dart';
import 'package:swamper_solution/models/individual_kyc_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/common/signup_screen/company_form.dart';
import 'package:swamper_solution/views/custom_widgets/crime_text_field.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';
import 'package:swamper_solution/views/custom_widgets/custom_drop_down.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';
import 'package:swamper_solution/views/custom_widgets/date_picker_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class IndividualKycApplicationScreen extends ConsumerStatefulWidget {
  const IndividualKycApplicationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IndividualKycApplicationScreenState();
}

class _IndividualKycApplicationScreenState
    extends ConsumerState<IndividualKycApplicationScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController transitController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController sinController = TextEditingController();
  final TextEditingController backCodeController = TextEditingController();
  final TextEditingController institutionNameController =
      TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController aptNoController = TextEditingController();
  final TextEditingController emergencyContactNumberController =
      TextEditingController();
  final TextEditingController emergencyContactNameController =
      TextEditingController();
  final TextEditingController offenceController = TextEditingController();
  final TextEditingController courtLocationController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Keys for scrolling to specific fields
  final GlobalKey firstNameKey = GlobalKey();
  final GlobalKey lastNameKey = GlobalKey();
  final GlobalKey genderKey = GlobalKey();
  final GlobalKey statusInCanadaKey = GlobalKey();
  final GlobalKey dobKey = GlobalKey();
  final GlobalKey addressKey = GlobalKey();
  final GlobalKey sinKey = GlobalKey();
  final GlobalKey sinExpiryKey = GlobalKey();
  final GlobalKey modeOfTravelKey = GlobalKey();
  final GlobalKey documentsKey = GlobalKey();
  final GlobalKey institutionKey = GlobalKey();
  final GlobalKey transitKey = GlobalKey();
  final GlobalKey accountKey = GlobalKey();
  final GlobalKey agreementsKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  String? selectedGender;
  String? selectedModeOfTravel;
  String? selectedStatusInCanada;
  String? govDocImage;
  String? permitImage;
  String? voidChequeImage;
  DateTime? selectedDobDate;
  DateTime? selectedSinExpiryDate;
  DateTime? dateOfSentence;
  bool isLoading = false;
  bool haveAgreedCanabasPolicy = false;
  bool haveAgreedToAntiViolancePolicy = false;
  bool haveAgreedToPrivacyPolicy = false;

  // Error states for better UI feedback
  bool genderError = false;
  bool statusInCanadaError = false;
  bool dobError = false;
  bool sinExpiryError = false;
  bool modeOfTravelError = false;
  bool documentsError = false;
  bool agreementsError = false;

  final List<String> genders = ["Male", "Female"];

  final List<String> statusInCanada = [
    "Study Permit",
    "Work Permit",
    "Permanent Resident",
    "Canadian Citizen",
  ];

  final List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  List<String> modeOfTravels = ["Car", "Transit"];

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Your DOB';
    return '${date.day.toString().padLeft(2, '0')} ${_monthNames[date.month - 1]} ${date.year}';
  }

  // Method to scroll to a specific field with error
  void _scrollToField(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1, // Position field near top of screen
      );
    }
  }

  // Enhanced validation method that shows specific errors and scrolls to invalid fields
  bool _validateFormWithScroll() {
    // Reset all error states
    setState(() {
      genderError = false;
      statusInCanadaError = false;
      dobError = false;
      sinExpiryError = false;
      modeOfTravelError = false;
      documentsError = false;
      agreementsError = false;
    });

    // First validate the form fields
    if (!formKey.currentState!.validate()) {
      // Find the first field with an error and scroll to it
      if (firstNameController.text.trim().isEmpty) {
        _scrollToField(firstNameKey);
        return false;
      }
      if (lastNameController.text.trim().isEmpty) {
        _scrollToField(lastNameKey);
        return false;
      }
      if (addressController.text.trim().isEmpty) {
        _scrollToField(addressKey);
        return false;
      }
      if (sinController.text.trim().isEmpty || sinController.text.length != 9) {
        _scrollToField(sinKey);
        return false;
      }
      if (institutionController.text.trim().length != 3) {
        _scrollToField(institutionKey);
        return false;
      }
      if (transitController.text.trim().length != 5) {
        _scrollToField(transitKey);
        return false;
      }
      if (accountNoController.text.trim().length > 12) {
        _scrollToField(accountKey);
        return false;
      }
      return false;
    }

    // Validate dropdown fields with error states
    if (selectedGender == null) {
      setState(() {
        genderError = true;
      });
      showCustomSnackBar(
        context: context,
        message: "Please select your gender",
        backgroundColor: AppColors().red,
      );
      _scrollToField(genderKey);
      return false;
    }

    if (selectedStatusInCanada == null) {
      setState(() {
        statusInCanadaError = true;
      });
      showCustomSnackBar(
        context: context,
        message: "Please select your status in Canada",
        backgroundColor: AppColors().red,
      );
      _scrollToField(statusInCanadaKey);
      return false;
    }

    if (selectedDobDate == null) {
      setState(() {
        dobError = true;
      });
      showCustomSnackBar(
        context: context,
        message: "Please select your date of birth",
        backgroundColor: AppColors().red,
      );
      _scrollToField(dobKey);
      return false;
    }

    if (selectedSinExpiryDate == null) {
      setState(() {
        sinExpiryError = true;
      });
      showCustomSnackBar(
        context: context,
        message: "Please select your SIN expiry date",
        backgroundColor: AppColors().red,
      );
      _scrollToField(sinExpiryKey);
      return false;
    }

    if (selectedModeOfTravel == null) {
      setState(() {
        modeOfTravelError = true;
      });
      showCustomSnackBar(
        context: context,
        message: "Please select your mode of travel",
        backgroundColor: AppColors().red,
      );
      _scrollToField(modeOfTravelKey);
      return false;
    }

    // Validate document uploads
    if ((_filePickerHelper.permitDoc == null &&
            _filePickerHelper.permitDocFile == null) ||
        (_filePickerHelper.govIdDoc == null &&
            _filePickerHelper.govIdDocFile == null) ||
        (_filePickerHelper.voidChequeDoc == null &&
            _filePickerHelper.voidChequeDocFile == null)) {
      setState(() {
        documentsError = true;
      });
      showCustomSnackBar(
        context: context,
        message: "Please upload all required documents",
        backgroundColor: Colors.red,
      );
      _scrollToField(documentsKey);
      return false;
    }

    // Validate agreements
    if (haveAgreedCanabasPolicy == false ||
        haveAgreedToAntiViolancePolicy == false ||
        haveAgreedToPrivacyPolicy == false) {
      setState(() {
        agreementsError = true;
      });
      showCustomSnackBar(
        context: context,
        message: "Please agree to all policies to continue",
        backgroundColor: AppColors().red,
      );
      _scrollToField(agreementsKey);
      return false;
    }

    return true;
  }

  Future<dynamic> showScroolDatePicker({
    required String title,
    required DateTime? initialDate,
    required Function(DateTime) onDateSelected,
    required bool isSinExpiry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DatePickerBottomSheet(
            isSinExpiry: isSinExpiry,
            title: title,
            initialDate: initialDate ?? DateTime.now(),
            onDateSelected: onDateSelected,
          ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    sinController.dispose();
    transitController.dispose();
    institutionController.dispose();
    accountNoController.dispose();
    backCodeController.dispose();
    institutionNameController.dispose();
    offenceController.dispose();
    courtLocationController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // go to URl
  Future<void> goToUrl(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  late final FilePickerHelper _filePickerHelper;

  @override
  void initState() {
    super.initState();
    _filePickerHelper = FilePickerHelper(
      onStateChanged: () {
        setState(() {
          // Clear documents error when any file is selected
          if ((_filePickerHelper.permitDoc != null ||
                  _filePickerHelper.permitDocFile != null) &&
              (_filePickerHelper.govIdDoc != null ||
                  _filePickerHelper.govIdDocFile != null) &&
              (_filePickerHelper.voidChequeDoc != null ||
                  _filePickerHelper.voidChequeDocFile != null)) {
            documentsError = false;
          }
        });
      },
    );
  }

  // image picker widget
  Widget _buildImagePickerBox({
    required String title,
    required String docType,
  }) {
    XFile? selectedImage;
    File? selectedDocFile;
    String? selectedDocFileName;
    switch (docType) {
      case "workPermit":
        selectedImage = _filePickerHelper.permitDoc;
        selectedDocFile = _filePickerHelper.permitDocFile;
        selectedDocFileName = _filePickerHelper.permitDocFileName;
        break;
      case "govId":
        selectedImage = _filePickerHelper.govIdDoc;
        selectedDocFile = _filePickerHelper.govIdDocFile;
        selectedDocFileName = _filePickerHelper.govIdDocFileName;
        break;
      case "voidCheque":
        selectedImage = _filePickerHelper.voidChequeDoc;
        selectedDocFile = _filePickerHelper.voidChequeDocFile;
        selectedDocFileName = _filePickerHelper.voidChequeDocFileName;
        break;
    }
    return Expanded(
      child: GestureDetector(
        onTap: () => _filePickerHelper.showUploadOptions(docType, context),
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: Radius.circular(8),
            color: Colors.black45,
            strokeWidth: 1,
            dashPattern: [5, 5],
          ),
          child: Center(
            child: Container(
              height: 150,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child:
                  selectedImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(selectedImage.path),
                          fit: BoxFit.cover,
                        ),
                      )
                      : (selectedDocFile != null && selectedDocFileName != null)
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description, size: 40, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            selectedDocFileName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, size: 40),
                          SizedBox(height: 8),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsnc = ref.watch(individualProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Due Diligence Form")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: userAsnc.when(
              data: (userData) {
                if (userData == null) {
                  return Center(child: Text("No user info available"));
                }
                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text("Fill your details to verify your Due Diligence."),
                      Row(
                        key: firstNameKey,
                        spacing: 8,
                        children: [
                          Expanded(
                            child: CustomTextfield(
                              hintText: "First name",
                              controller:
                                  firstNameController
                                    ..text = userData.firstName,
                              obscureText: false,
                              textInputType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter first name';
                                }
                                return null;
                              },
                            ),
                          ),
                          Expanded(
                            key: lastNameKey,
                            child: CustomTextfield(
                              hintText: "Last name",
                              controller:
                                  lastNameController..text = userData.lastName,
                              obscureText: false,
                              textInputType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter last name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // Gender Selection Drop Down
                      Container(
                        key: genderKey,
                        decoration:
                            genderError
                                ? BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                                : null,
                        child: CustomDropDown(
                          value: selectedGender,
                          hintText: "Select your Gender",
                          options: genders,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                              genderError =
                                  false; // Clear error when selection is made
                            });
                          },
                        ),
                      ),

                      // Status in Canada dropdown
                      Container(
                        key: statusInCanadaKey,
                        decoration:
                            statusInCanadaError
                                ? BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                                : null,
                        child: CustomDropDown(
                          value: selectedStatusInCanada,
                          hintText: "Status in Canada",
                          options: statusInCanada,
                          onChanged: (value) {
                            setState(() {
                              selectedStatusInCanada = value;
                              statusInCanadaError =
                                  false; // Clear error when selection is made
                            });
                          },
                        ),
                      ),

                      Container(
                        key: dobKey,
                        decoration:
                            dobError
                                ? BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                                : null,
                        child: CustomButton(
                          backgroundColor: Colors.green,
                          onPressed: () {
                            showScroolDatePicker(
                              isSinExpiry: false,
                              title: "Select Date of Birth",
                              initialDate: selectedDobDate,
                              onDateSelected: (DateTime date) {
                                setState(() {
                                  selectedDobDate = date;
                                  dobError =
                                      false; // Clear error when date is selected
                                });
                              },
                            );
                          },
                          text:
                              selectedDobDate != null
                                  ? _formatDate(selectedDobDate)
                                  : "Select Your DOB",
                          textColor: Colors.white,
                        ),
                      ),
                      Container(
                        key: addressKey,
                        child: CustomTextfield(
                          hintText: "Permanent Address",
                          controller:
                              addressController..text = userData.address,
                          obscureText: false,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        key: sinKey,
                        child: CustomTextfield(
                          hintText: "SIN No",
                          controller: sinController,
                          obscureText: false,
                          textInputType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your SIN no';
                            }
                            if (value.length != 9) {
                              return 'Invalid SIN no';
                            }
                            return null;
                          },
                        ),
                      ),

                      // should be a date picker
                      Container(
                        key: sinExpiryKey,
                        decoration:
                            sinExpiryError
                                ? BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                                : null,
                        child: CustomButton(
                          haveBorder: true,
                          borderColor: Colors.black,
                          backgroundColor: AppColors().backgroundColor,
                          onPressed: () {
                            showScroolDatePicker(
                              isSinExpiry: true,
                              title: "Select SIN Expiry Date",
                              initialDate: selectedSinExpiryDate,
                              onDateSelected: (DateTime date) {
                                setState(() {
                                  selectedSinExpiryDate = date;
                                  sinExpiryError =
                                      false; // Clear error when date is selected
                                });
                              },
                            );
                          },
                          text:
                              selectedSinExpiryDate != null
                                  ? _formatDate(selectedSinExpiryDate)
                                  : "SIN Expiry Date",
                          textColor: AppColors().black,
                        ),
                      ),

                      CustomTextfield(
                        hintText: "APT / Suite No",
                        controller: aptNoController,
                        obscureText: false,
                        textInputType: TextInputType.text,
                      ),

                      CustomTextfield(
                        hintText: "Postal Code",
                        controller: postalCodeController,
                        obscureText: false,
                        textInputType: TextInputType.text,
                      ),
                      CustomTextfield(
                        hintText: "Emergency Contact Number",
                        controller: emergencyContactNumberController,
                        obscureText: false,
                        textInputType: TextInputType.numberWithOptions(),
                      ),
                      CustomTextfield(
                        hintText: "Emergency Contact Name",
                        controller: emergencyContactNameController,
                        obscureText: false,
                        textInputType: TextInputType.name,
                      ),
                      Container(
                        key: modeOfTravelKey,
                        decoration:
                            modeOfTravelError
                                ? BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                                : null,
                        child: CustomDropDown(
                          value: selectedModeOfTravel,
                          hintText: "Mode of travel",
                          options: modeOfTravels,
                          onChanged: (value) {
                            setState(() {
                              selectedModeOfTravel = value;
                              modeOfTravelError =
                                  false; // Clear error when selection is made
                            });
                          },
                        ),
                      ),

                      Container(
                        key: documentsKey,
                        decoration:
                            documentsError
                                ? BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                                : null,
                        child: Row(
                          spacing: 12,
                          children: [
                            _buildImagePickerBox(
                              title: 'Upload Study/Work\nPermit',
                              docType: "workPermit",
                            ),
                            _buildImagePickerBox(
                              title: 'Upload Gov ID/\nPassport',
                              docType: "govId",
                            ),
                          ],
                        ),
                      ),
                      CustomDivider(text: "Bank Details"),
                      Container(
                        key: institutionKey,
                        child: CustomTextfield(
                          hintText: "Institution No",
                          controller: institutionController,
                          obscureText: false,
                          textInputType: TextInputType.number,
                          validator: (value) {
                            if (value?.length != 3) {
                              return 'Invalid Institution No';
                            }
                            return null;
                          },
                        ),
                      ),

                      CustomTextfield(
                        hintText: "Institution Name",
                        controller: institutionNameController,
                        obscureText: false,
                        textInputType: TextInputType.text,
                      ),

                      Container(
                        key: transitKey,
                        child: CustomTextfield(
                          hintText: "Transit No",
                          controller: transitController,
                          obscureText: false,
                          textInputType: TextInputType.number,
                          validator: (value) {
                            if (value?.length != 5) {
                              return "Invalid Transit no";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        key: accountKey,
                        child: CustomTextfield(
                          hintText: "Account No",
                          controller: accountNoController,
                          obscureText: false,
                          textInputType: TextInputType.number,
                          validator: (value) {
                            if (value!.length > 12) {
                              return 'Invalid Account No';
                            }
                            return null;
                          },
                        ),
                      ),

                      Row(
                        children: [
                          _buildImagePickerBox(
                            title: "Void Cheque",
                            docType: "voidCheque",
                          ),
                        ],
                      ),

                      CustomDivider(text: "Criminal Records"),
                      Consumer(
                        builder: (context, ref, child) {
                          final hasCriminalRecords = ref.watch(
                            criminalProvider,
                          );
                          final crimeList = ref.watch(crimeListProvider);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Do you have any criminal record?"),
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      groupValue: hasCriminalRecords,
                                      onChanged: (value) {
                                        ref
                                            .read(criminalProvider.notifier)
                                            .state = value!;
                                      },
                                    ),
                                    Text("Yes"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: false,
                                      groupValue: hasCriminalRecords,
                                      onChanged: (value) {
                                        ref
                                            .read(criminalProvider.notifier)
                                            .state = value!;
                                      },
                                    ),
                                    Text("No"),
                                  ],
                                ),
                                if (hasCriminalRecords) ...[
                                  SizedBox(height: 12),
                                  Card(
                                    elevation: 0,
                                    color: const Color.fromARGB(20, 0, 0, 0),
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Add Crime Details",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: CrimeTextField(
                                                  controller: offenceController,
                                                  text: "Offence",
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                flex: 2,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final pickedDate =
                                                        await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              dateOfSentence ??
                                                              DateTime.now(),
                                                          firstDate: DateTime(
                                                            1900,
                                                          ),
                                                          lastDate:
                                                              DateTime.now(),
                                                        );
                                                    if (pickedDate != null) {
                                                      setState(() {
                                                        dateOfSentence =
                                                            pickedDate;
                                                      });
                                                    }
                                                  },
                                                  child: AbsorbPointer(
                                                    child: CrimeTextField(
                                                      controller:
                                                          TextEditingController(
                                                            text:
                                                                dateOfSentence !=
                                                                        null
                                                                    ? _formatDate(
                                                                      dateOfSentence,
                                                                    )
                                                                    : '',
                                                          ),
                                                      text: "Date Sentenced",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                flex: 2,
                                                child: CrimeTextField(
                                                  controller:
                                                      courtLocationController,
                                                  text: "Court Location",
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,

                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                if (offenceController
                                                        .text
                                                        .isNotEmpty &&
                                                    dateOfSentence != null &&
                                                    courtLocationController
                                                        .text
                                                        .isNotEmpty) {
                                                  ref
                                                      .read(
                                                        crimeListProvider
                                                            .notifier,
                                                      )
                                                      .state = [
                                                    ...crimeList,
                                                    CrimersModel(
                                                      offence:
                                                          offenceController.text
                                                              .trim(),
                                                      dateOfSentence:
                                                          dateOfSentence!,
                                                      courtLocation:
                                                          courtLocationController
                                                              .text
                                                              .trim(),
                                                    ),
                                                  ];
                                                  offenceController.clear();
                                                  dateOfSentence = null;
                                                  courtLocationController
                                                      .clear();
                                                } else {
                                                  showCustomSnackBar(
                                                    context: context,
                                                    message:
                                                        "Fill all the Crime deails!",
                                                    backgroundColor:
                                                        AppColors().red,
                                                  );
                                                }
                                              },
                                              icon: Icon(Icons.add),
                                              label: Text("Add Crime"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (crimeList.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        Text(
                                          "Added Crimes:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ...crimeList.asMap().entries.map(
                                          (entry) => Card(
                                            elevation: 0,
                                            color: const Color.fromARGB(
                                              20,
                                              0,
                                              0,
                                              0,
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: ListTile(
                                              title: Text(entry.value.offence),
                                              subtitle: Text(
                                                'Date: ${entry.value.dateOfSentence.day.toString().padLeft(2, '0')} \\${_monthNames[entry.value.dateOfSentence.month - 1]} \\${entry.value.dateOfSentence.year}\nCourt: ${entry.value.courtLocation}',
                                              ),
                                              trailing: IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  final updatedList = [
                                                    ...crimeList,
                                                  ];
                                                  updatedList.removeAt(
                                                    entry.key,
                                                  );
                                                  ref
                                                      .read(
                                                        crimeListProvider
                                                            .notifier,
                                                      )
                                                      .state = updatedList;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),

                      CustomDivider(text: "Cannabas Policy"),

                      Container(
                        key: agreementsKey,
                        decoration:
                            agreementsError
                                ? BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                                : null,
                        padding: agreementsError ? EdgeInsets.all(8) : null,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: haveAgreedCanabasPolicy,
                                  onChanged: (value) {
                                    setState(() {
                                      haveAgreedCanabasPolicy = value!;
                                      if (haveAgreedCanabasPolicy &&
                                          haveAgreedToAntiViolancePolicy &&
                                          haveAgreedToPrivacyPolicy) {
                                        agreementsError =
                                            false; // Clear error when all agreements are checked
                                      }
                                    });
                                  },
                                ),
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      style: CustomTextStyles.lightText
                                          .copyWith(color: Colors.black),
                                      children: [
                                        const TextSpan(
                                          text: 'Agree to all the ',
                                        ),
                                        TextSpan(
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  goToUrl(
                                                    "https://swampersolutions.com/privacy-policy",
                                                  );
                                                },
                                          text:
                                              'Recreational Cannabis Policy of Swamper',
                                          style: CustomTextStyles.lightText
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors().primaryColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: haveAgreedToAntiViolancePolicy,
                                  onChanged: (value) {
                                    setState(() {
                                      haveAgreedToAntiViolancePolicy = value!;
                                      if (haveAgreedCanabasPolicy &&
                                          haveAgreedToAntiViolancePolicy &&
                                          haveAgreedToPrivacyPolicy) {
                                        agreementsError =
                                            false; // Clear error when all agreements are checked
                                      }
                                    });
                                  },
                                ),
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      style: CustomTextStyles.lightText
                                          .copyWith(color: Colors.black),
                                      children: [
                                        const TextSpan(
                                          text: 'Agree to all the ',
                                        ),
                                        TextSpan(
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  goToUrl(
                                                    "https://swampersolutions.com/privacy-policy",
                                                  );
                                                },
                                          text:
                                              'Anti-violance Policy of Swamper',
                                          style: CustomTextStyles.lightText
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors().primaryColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Checkbox(
                                  value: haveAgreedToPrivacyPolicy,
                                  onChanged: (value) {
                                    setState(() {
                                      haveAgreedToPrivacyPolicy = value!;
                                      if (haveAgreedCanabasPolicy &&
                                          haveAgreedToAntiViolancePolicy &&
                                          haveAgreedToPrivacyPolicy) {
                                        agreementsError =
                                            false; // Clear error when all agreements are checked
                                      }
                                    });
                                  },
                                ),
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      style: CustomTextStyles.lightText
                                          .copyWith(color: Colors.black),
                                      children: [
                                        const TextSpan(
                                          text: 'Agree to all the ',
                                        ),
                                        TextSpan(
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  goToUrl(
                                                    "https://swampersolutions.com/privacy-policy",
                                                  );
                                                },
                                          text: 'Privacy Policy of Swamper',
                                          style: CustomTextStyles.lightText
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors().primaryColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      CustomButton(
                        backgroundColor: AppColors().primaryColor,
                        onPressed: () async {
                          // Use enhanced validation with scrolling
                          if (!_validateFormWithScroll()) {
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          // Upload images/documents now
                          String? permitUrl;
                          String? govDocUrl;
                          String? voidChequeUrl;

                          // Upload permit document
                          if (_filePickerHelper.permitDoc != null) {
                            permitUrl = await KycController().uploadDoc(
                              userData.uid,
                              _filePickerHelper.permitDoc!,
                              "workPermit",
                            );
                          } else if (_filePickerHelper.permitDocFile != null) {
                            permitUrl = await KycController()
                                .uploadDocumentFile(
                                  userData.uid,
                                  _filePickerHelper.permitDocFile!,
                                  "workPermit",
                                  _filePickerHelper.permitDocFileName!,
                                );
                          }

                          // Upload government ID document
                          if (_filePickerHelper.govIdDoc != null) {
                            govDocUrl = await KycController().uploadDoc(
                              userData.uid,
                              _filePickerHelper.govIdDoc!,
                              "govId",
                            );
                          } else if (_filePickerHelper.govIdDocFile != null) {
                            govDocUrl = await KycController()
                                .uploadDocumentFile(
                                  userData.uid,
                                  _filePickerHelper.govIdDocFile!,
                                  "govId",
                                  _filePickerHelper.govIdDocFileName!,
                                );
                          }

                          // Upload void cheque document
                          if (_filePickerHelper.voidChequeDoc != null) {
                            voidChequeUrl = await KycController().uploadDoc(
                              userData.uid,
                              _filePickerHelper.voidChequeDoc!,
                              "voidCheque",
                            );
                          } else if (_filePickerHelper.voidChequeDocFile !=
                              null) {
                            voidChequeUrl = await KycController()
                                .uploadDocumentFile(
                                  userData.uid,
                                  _filePickerHelper.voidChequeDocFile!,
                                  "voidCheque",
                                  _filePickerHelper.voidChequeDocFileName!,
                                );
                          }

                          // Check if all uploads were successful
                          if (permitUrl == null ||
                              govDocUrl == null ||
                              voidChequeUrl == null) {
                            showCustomSnackBar(
                              context: context,
                              message:
                                  "Failed to upload documents. Please try again.",
                              backgroundColor: AppColors().red,
                            );
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }

                          final IndividualKycModel
                          kycApplication = IndividualKycModel(
                            userInfo: userData.copyWith(kycVerified: "pending"),
                            dob: selectedDobDate!.toString(),
                            gender: selectedGender!,
                            sinNumber: sinController.text.trim(),
                            sinExpiry: selectedSinExpiryDate!.toString(),
                            transitNumber: transitController.text.trim(),
                            institutionNumber:
                                institutionController.text.trim(),
                            bankAccNumber: accountNoController.text.trim(),
                            statusInCanada: selectedStatusInCanada!,
                            permitImage: permitUrl,
                            govDocImage: govDocUrl,
                            institutionName:
                                institutionNameController.text.trim(),
                            voidCheque: voidChequeUrl,
                            aptNo: aptNoController.text.trim(),
                            emergencyContactNo:
                                emergencyContactNumberController.text.trim(),
                            emergencyContactName:
                                emergencyContactNameController.text.trim(),
                            modeOfTravel: selectedModeOfTravel!,
                            postalCode: postalCodeController.text.trim(),
                            haveCriminalRecord: ref.read(criminalProvider),
                            crimes: ref.read(crimeListProvider),
                            appliedDate: DateTime.now().toString(),
                          );

                          final status = await KycController().applyKyc(
                            kycApplication,
                            userData,
                          );
                          if (status) {
                            showCustomSnackBar(
                              context: context,
                              message: "Due Diligence Application Submitted",
                              backgroundColor: AppColors().green,
                            );
                            context.goNamed("kyc_status_screen");
                          } else {
                            showCustomSnackBar(
                              context: context,
                              message:
                                  "Failed to send Due Diligence Application !",
                              backgroundColor: AppColors().red,
                            );
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                        isLoading: isLoading,
                        text: "Send Due Diligence Application",
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                );
              },
              error: (error, stack) {
                return Center(child: Text("Error Occoured: $error"));
              },
              loading: () {
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  final String text;
  const CustomDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Expanded(child: Divider()),
          Text(text),
          Expanded(child: Divider()),
        ],
      ),
    );
  }
}
