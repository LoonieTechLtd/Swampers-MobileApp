import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/kyc_controller.dart';
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
  final TextEditingController sinExpiryController = TextEditingController();
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
  String? selectedGender;
  String? selectedModeOfTravel;
  String? selectedStatusInCanada;
  String? govDocImage;
  String? permitImage;
  String? voidChequeImage;
  DateTime? selectedDate;
  DateTime? dateOfSentence;
  bool isLoading = false;
  bool haveAgreedCanabasPolicy = false;
  bool haveAgreedToAntiViolancePolicy = false;
  bool haveAgreedToPrivacyPolicy = false;

  final List<String> genders = ["Male", "Female"];

  final List<String> statusInCanada = [
    "Study Permit",
    "Work Permit",
    "Permanent Resident",
    "Citizenship",
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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    sinController.dispose();
    transitController.dispose();
    institutionController.dispose();
    accountNoController.dispose();
    sinExpiryController.dispose();
    backCodeController.dispose();
    institutionNameController.dispose();
    offenceController.dispose();
    courtLocationController.dispose();

    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? permitDoc;
  XFile? govIdDoc;
  XFile? voidChequeDoc;

  // go to URl
  Future<void> goToUrl(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  // to pick doc images
  Future<void> pickImage(String docType) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (docType == "workPermit") {
            permitDoc = image;
          }
          if (docType == "govId") {
            govIdDoc = image;
          }
          if (docType == "voidCheque") {
            voidChequeDoc = image;
          }
        });

        final url = await KycController().uploadDoc(
          ref.read(individualProvider).value!.uid,
          image,
          docType,
        );

        setState(() {
          if (docType == "workPermit") {
            permitImage = url;
          }
          if (docType == "govId") {
            govDocImage = url;
          }
          if (docType == "voidCheque") {
            voidChequeImage = url;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // image picker widget
  Widget _buildImagePickerBox({
    required String title,
    required String docType,
    XFile? selectedImage,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => pickImage(docType),
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
      appBar: AppBar(title: Text("KYC Application Form")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
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
                      Text("Fill your details to verify your KYC."),
                      Row(
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
                      CustomDropDown(
                        value: selectedGender,
                        hintText: "Select your Gender",
                        options: genders,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),

                      // Status in Canada dropdown
                      CustomDropDown(
                        value: selectedStatusInCanada,
                        hintText: "Status in Canada",
                        options: statusInCanada,
                        onChanged: (value) {
                          selectedStatusInCanada = value;
                        },
                      ),

                      CustomButton(
                        backgroundColor: Colors.green,
                        onPressed: () async {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder:
                                (context) => DatePickerBottomSheet(
                                  initialDate: selectedDate,
                                  onDateSelected: (DateTime date) {
                                    setState(() {
                                      selectedDate = date;
                                    });
                                  },
                                ),
                          );
                        },
                        text:
                            selectedDate != null
                                ? _formatDate(selectedDate)
                                : "Select Your DOB",
                        textColor: Colors.white,
                      ),
                      CustomTextfield(
                        hintText: "Permanent Address",
                        controller: addressController..text = userData.address,
                        obscureText: false,
                        textInputType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      CustomTextfield(
                        hintText: "SIN No",
                        controller: sinController,
                        obscureText: false,
                        textInputType: TextInputType.text,
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
                      CustomTextfield(
                        hintText: "SIN Expiry",
                        controller: sinExpiryController,
                        obscureText: false,
                        textInputType: TextInputType.text,
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
                      CustomDropDown(
                        value: selectedModeOfTravel,
                        hintText: "Mode of travel",
                        options: modeOfTravels,
                        onChanged: (value) {
                          selectedModeOfTravel = value;
                        },
                      ),

                      Row(
                        spacing: 12,
                        children: [
                          _buildImagePickerBox(
                            title: 'Upload Study/Work\nPermit',
                            docType: "workPermit",
                            selectedImage: permitDoc,
                          ),
                          _buildImagePickerBox(
                            title: 'Upload Gov ID/\nPassport',
                            docType: "govId",
                            selectedImage: govIdDoc,
                          ),
                        ],
                      ),
                      CustomDivider(text: "Bank Details"),

                      CustomTextfield(
                        hintText: "Bank Code",
                        controller: backCodeController,
                        obscureText: false,
                        textInputType: TextInputType.text,
                        validator: (value) {
                          if (value?.length != 4) {
                            return 'Invalid Bank Code';
                          }
                          return null;
                        },
                      ),

                      CustomTextfield(
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

                      CustomTextfield(
                        hintText: "Institution Name",
                        controller: institutionNameController,
                        obscureText: false,
                        textInputType: TextInputType.text,
                      ),

                      CustomTextfield(
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
                      CustomTextfield(
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

                      Row(
                        children: [
                          _buildImagePickerBox(
                            title: "Void Cheque",
                            docType: "voidCheque",
                            selectedImage: voidChequeDoc,
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

                      Row(
                        children: [
                          Checkbox(
                            value: haveAgreedCanabasPolicy,
                            onChanged: (value) {
                              setState(() {
                                haveAgreedCanabasPolicy = value!;
                              });
                            },
                          ),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                style: CustomTextStyles.lightText.copyWith(
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(text: 'Agree to all the '),
                                  TextSpan(
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            goToUrl(
                                              "https://swampersolutions.com/Cannabis-Policy",
                                            );
                                          },
                                    text:
                                        'Recreational Cannabis Policy of Swamper',
                                    style: CustomTextStyles.lightText.copyWith(
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
                              });
                            },
                          ),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                style: CustomTextStyles.lightText.copyWith(
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(text: 'Agree to all the '),
                                  TextSpan(
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            goToUrl(
                                              "https://swampersolutions.com/Anti-violence-Policy",
                                            );
                                          },
                                    text: 'Anti-violance Policy of Swamper',
                                    style: CustomTextStyles.lightText.copyWith(
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
                              });
                            },
                          ),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                style: CustomTextStyles.lightText.copyWith(
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(text: 'Agree to all the '),
                                  TextSpan(
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            goToUrl(
                                              "https://swampersolutions.com/Privacy-Policy",
                                            );
                                          },
                                    text: 'Privacy Policy of Swamper',
                                    style: CustomTextStyles.lightText.copyWith(
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

                      CustomButton(
                        backgroundColor: AppColors().primaryColor,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          if (selectedDate == null) {
                            showCustomSnackBar(
                              context: context,
                              message: "Please Select your DOB",
                              backgroundColor: AppColors().red,
                            );
                            return;
                          }

                          if (selectedGender == null) {
                            showCustomSnackBar(
                              context: context,
                              message: "Please Select your gender",
                              backgroundColor: AppColors().red,
                            );
                            return;
                          }
                          if (selectedModeOfTravel == null) {
                            showCustomSnackBar(
                              context: context,
                              message: "Please Select your Mode of Travel",
                              backgroundColor: AppColors().red,
                            );
                            return;
                          }

                          if (permitDoc == null || govIdDoc == null || voidChequeDoc == null) {
                            showCustomSnackBar(
                              context: context,
                              message: "Please all documents images",
                              backgroundColor: Colors.red,
                            );
                            return;
                          }
                          if (haveAgreedCanabasPolicy == false ||
                              haveAgreedToAntiViolancePolicy == false ||
                              haveAgreedToPrivacyPolicy == false) {
                            showCustomSnackBar(
                              context: context,
                              message:
                                  "Must mark all the agreement to continue",
                              backgroundColor: AppColors().red,
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          final IndividualKycModel
                          kycApplication = IndividualKycModel(
                            userInfo: userData.copyWith(kycVerified: "pending"),
                            dob: selectedDate!.toString(),
                            gender: selectedGender!,
                            sinNumber: sinController.text.trim(),
                            sinExpiry: sinExpiryController.text.trim(),
                            transitNumber: transitController.text.trim(),
                            institutionNumber:
                                institutionController.text.trim(),
                            bankAccNumber: accountNoController.text.trim(),
                            statusInCanada: selectedStatusInCanada!,
                            permitImage: permitImage!,
                            govDocImage: govDocImage!,
                            institutionName:
                                institutionNameController.text.trim(),
                            voidCheque: voidChequeImage!,
                            bankCode: backCodeController.text.trim(),
                            aptNo: aptNoController.text.trim(),
                            emergencyContactNo:
                                emergencyContactNumberController.text.trim(),
                            emergencyContactName:
                                emergencyContactNameController.text.trim(),
                            modeOfTravel: selectedModeOfTravel!,
                            postalCode: postalCodeController.text.trim(),
                            haveCriminalRecord: ref.read(criminalProvider),
                            crimes: ref.read(crimeListProvider),
                          );

                          final status = await KycController().applyKyc(
                            kycApplication,
                            userData,
                          );
                          if (status) {
                            showCustomSnackBar(
                              context: context,
                              message: "KYC Application Submitted",
                              backgroundColor: AppColors().green,
                            );
                            context.goNamed("kyc_status_screen");
                          } else {
                            showCustomSnackBar(
                              context: context,
                              message: "Failed to send KYC application !",
                              backgroundColor: AppColors().red,
                            );
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                        isLoading: isLoading,
                        text: "Send KYC Application",
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
