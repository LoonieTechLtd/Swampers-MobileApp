import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/app_colors.dart';
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

class EditKycScreen extends ConsumerStatefulWidget {
  const EditKycScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IndividualKycApplicationScreenState();
}

class _IndividualKycApplicationScreenState
    extends ConsumerState<EditKycScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController transitController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController sinController = TextEditingController();
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
  final GlobalKey<FormState> crimeKey = GlobalKey<FormState>();
  String? selectedGender;
  String? selectedModeOfTravel;
  String? selectedStatusInCanada;
  String? govDocImage;
  String? permitImage;
  String? voidChequeImage;
  DateTime? selectedDate;
  DateTime? selectedSinExpiryDate;
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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    sinController.dispose();
    transitController.dispose();
    institutionController.dispose();
    accountNoController.dispose();
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

  List<CrimersModel> localCrimeList = [];

  // image picker widget
  Widget _buildImagePickerBox({
    required String title,
    required String docType,
    XFile? selectedImage,
    String? imageUrl,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
          );
          if (image != null) {
            setState(() {
              if (docType == "workPermit") permitDoc = image;
              if (docType == "govId") govIdDoc = image;
              if (docType == "voidCheque") voidChequeDoc = image;
            });
            final url = await KycController().uploadDoc(
              ref.read(individualProvider).value!.uid,
              image,
              docType,
            );
            setState(() {
              if (docType == "workPermit") permitImage = url;
              if (docType == "govId") govDocImage = url;
              if (docType == "voidCheque") voidChequeImage = url;
            });
          }
        },
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
                      : (imageUrl != null && imageUrl.isNotEmpty)
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(imageUrl, fit: BoxFit.cover),
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

  bool? localHaveCriminalRecord;

  @override
  Widget build(BuildContext context) {
    final kycAsnc = ref.watch(getKycData);

    return Scaffold(
      appBar: AppBar(title: Text("Edit your Due Diligence")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            child: kycAsnc.when(
              data: (kycData) {
                final k = kycData;
                final crimesList = k?.crimes;
                void addCrime(CrimersModel crime) {
                  setState(() {
                    localCrimeList.add(crime);
                  });
                  offenceController.clear();
                  dateOfSentence = null;
                  courtLocationController.clear();
                }

                void removeCrime(int index) {
                  setState(() {
                    localCrimeList.removeAt(index);
                  });
                }

                if (localCrimeList.isEmpty && crimesList != null) {
                  localCrimeList = List<CrimersModel>.from(crimesList);
                }
                if (kycData == null) {
                  return Center(child: Text("No user info available"));
                }

                // --- Initialize localHaveCriminalRecord from kycData if null ---
                localHaveCriminalRecord ??= kycData.haveCriminalRecord;

                // --- DOB: Pre-fill selectedDate from kycData.dob if not already set ---
                if (selectedDate == null && kycData.dob.isNotEmpty) {
                  try {
                    selectedDate = DateTime.tryParse(kycData.dob);
                  } catch (_) {
                    selectedDate = null;
                  }
                }

                 if (selectedSinExpiryDate == null && kycData.sinExpiry.isNotEmpty) {
                  try {
                    selectedSinExpiryDate = DateTime.tryParse(kycData.sinExpiry);
                  } catch (_) {
                    selectedSinExpiryDate = null;
                  }
                }

                // --- Crimes: Pre-fill crimeListProvider from kycData.crimes if not already set ---
                final crimeList = ref.watch(crimeListProvider);
                if ((crimeList.isEmpty ||
                        crimeList.length != (kycData.crimes?.length ?? 0)) &&
                    (kycData.crimes != null && kycData.crimes!.isNotEmpty)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref
                        .read(crimeListProvider.notifier)
                        .state = List<CrimersModel>.from(kycData.crimes!);
                  });
                }

                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text("Fill your details to verify your Due Diligence."),
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: CustomTextfield(
                              hintText: "First name",
                              controller:
                                  firstNameController
                                    ..text = kycData.userInfo.firstName,
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
                                  lastNameController
                                    ..text = kycData.userInfo.lastName,
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
                        value: kycData.gender,
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
                        value: kycData.statusInCanada,
                        hintText: "Status in Canada",
                        options: statusInCanada,
                        onChanged: (value) {
                          selectedStatusInCanada = value;
                        },
                      ),

                      // --- DOB Button, now pre-filled from selectedDate (from kycData.dob) ---
                      CustomButton(
                        backgroundColor: Colors.green,
                        onPressed: () async {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder:
                                (context) => DatePickerBottomSheet(
                                  isSinExpiry: false,
                                  title: "Select Date of Birth",
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
                                : (kycData.dob.isNotEmpty
                                    ? kycData.dob
                                    : "Select Your DOB"),
                        textColor: Colors.white,
                      ),
                      CustomTextfield(
                        hintText: "Permanent Address",
                        controller:
                            addressController..text = kycData.userInfo.address,
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
                        controller: sinController..text = kycData.sinNumber,
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

                      // SIN Expiry Selector
                      CustomButton(
                        backgroundColor: AppColors().backgroundColor,
                        haveBorder: true,
                        borderColor: AppColors().black,
                      textColor:AppColors().black,
                        onPressed: () async {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder:
                                (context) => DatePickerBottomSheet(
                                  isSinExpiry: true,
                                  title: "Select SIN expiry date",
                                  initialDate: selectedSinExpiryDate,
                                  onDateSelected: (DateTime date) {
                                    setState(() {
                                      selectedSinExpiryDate = date;
                                    });
                                  },
                                ),
                          );
                        },
                        text:
                            selectedSinExpiryDate != null
                                ? _formatDate(selectedSinExpiryDate)
                                : (kycData.sinExpiry.isNotEmpty
                                    ? _formatDate(selectedSinExpiryDate)
                                    : "SIN Expiry date"),
                      ),

                      CustomTextfield(
                        hintText: "APT / Suite No",
                        controller: aptNoController..text = kycData.aptNo,
                        obscureText: false,
                        textInputType: TextInputType.text,
                      ),

                      CustomTextfield(
                        hintText: "Postal Code",
                        controller:
                            postalCodeController..text = kycData.postalCode,
                        obscureText: false,
                        textInputType: TextInputType.text,
                      ),
                      CustomTextfield(
                        hintText: "Emergency Contact Number",
                        controller:
                            emergencyContactNumberController
                              ..text = kycData.emergencyContactNo,
                        obscureText: false,
                        textInputType: TextInputType.numberWithOptions(),
                      ),
                      CustomTextfield(
                        hintText: "Emergency Contact Name",
                        controller:
                            emergencyContactNameController
                              ..text = kycData.emergencyContactName,
                        obscureText: false,
                        textInputType: TextInputType.name,
                      ),
                      CustomDropDown(
                        value: kycData.modeOfTravel,
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
                            imageUrl: permitDoc == null ? k?.permitImage : null,
                          ),
                          _buildImagePickerBox(
                            title: 'Upload Gov ID/\nPassport',
                            docType: "govId",
                            selectedImage: govIdDoc,
                            imageUrl: govIdDoc == null ? k?.govDocImage : null,
                          ),
                        ],
                      ),
                      CustomDivider(text: "Bank Details"),
                      CustomTextfield(
                        hintText: "Institution No",
                        controller:
                            institutionController
                              ..text = kycData.institutionNumber,
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
                        controller:
                            institutionNameController
                              ..text = kycData.institutionName,
                        obscureText: false,
                        textInputType: TextInputType.text,
                      ),

                      CustomTextfield(
                        hintText: "Transit No",
                        controller:
                            transitController..text = kycData.transitNumber,
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
                        controller:
                            accountNoController..text = kycData.bankAccNumber,
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
                            imageUrl:
                                voidChequeDoc == null ? k?.voidCheque : null,
                          ),
                        ],
                      ),
                      CustomDivider(text: "Criminal Records"),

                      Row(
                        children: [
                          Text(
                            "Do you have a criminal record?",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: localHaveCriminalRecord ?? false,
                            onChanged: (val) {
                              setState(() {
                                localHaveCriminalRecord = val;
                                if (!val) {
                                  localCrimeList.clear();
                                }
                              });
                            },
                          ),
                        ],
                      ),

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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add Crime Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Form(
                                key: crimeKey,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: CrimeTextField(
                                        controller: offenceController,
                                        text: "Offence",
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Enter Offence";
                                          }
                                          return null;
                                        },
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
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime.now(),
                                              );
                                          if (pickedDate != null) {
                                            setState(() {
                                              dateOfSentence = pickedDate;
                                            });
                                          }
                                        },
                                        child: AbsorbPointer(
                                          child: CrimeTextField(
                                            controller: TextEditingController(
                                              text:
                                                  dateOfSentence != null
                                                      ? _formatDate(
                                                        dateOfSentence,
                                                      )
                                                      : '',
                                            ),
                                            text: "Date Sentenced",
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Enter Date";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: CrimeTextField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Enter Location";
                                          }
                                          return null;
                                        },
                                        controller: courtLocationController,
                                        text: "Court Location",
                                      ),
                                    ),
                                  ],
                                ),
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (!crimeKey.currentState!.validate()) {
                                      return;
                                    }
                                    CrimersModel crime = CrimersModel(
                                      offence: offenceController.text,
                                      dateOfSentence: dateOfSentence!,
                                      courtLocation:
                                          courtLocationController.text,
                                    );
                                    addCrime(crime);
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text("Add Crime"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if ((localHaveCriminalRecord ?? false) &&
                          localCrimeList.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: localCrimeList.length,
                          itemBuilder: (context, index) {
                            final crime = localCrimeList[index];
                            return Card(
                              child: ListTile(
                                title: Text(crime.offence),
                                subtitle: Text(
                                  'Court: ${crime.courtLocation}\nDate: ${crime.dateOfSentence.toString().split(' ')[0]}',
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => removeCrime(index),
                                ),
                              ),
                            );
                          },
                        ),
                      CustomButton(
                        backgroundColor: AppColors().primaryColor,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() {
                            isLoading = true;
                          });
                          final IndividualKycModel updatedKyc =
                              IndividualKycModel(
                                userInfo: k!.userInfo,
                                dob: selectedDate.toString(),
                                gender:selectedGender?? k.gender,
                                sinNumber: sinController.text,
                                sinExpiry: selectedSinExpiryDate.toString(),
                                transitNumber: transitController.text,
                                institutionNumber: institutionController.text,
                                institutionName: institutionNameController.text,
                                voidCheque: voidChequeImage ?? k.voidCheque,
                                bankAccNumber: accountNoController.text,
                                statusInCanada:
                                    selectedStatusInCanada ?? k.statusInCanada,
                                permitImage: permitImage ?? k.permitImage,
                                govDocImage: govDocImage ?? k.govDocImage,
                                aptNo: aptNoController.text,
                                emergencyContactNo:
                                    emergencyContactNumberController.text,
                                emergencyContactName:
                                    emergencyContactNameController.text,
                                modeOfTravel:
                                    selectedModeOfTravel ?? k.modeOfTravel,
                                postalCode: postalCodeController.text,
                                haveCriminalRecord:
                                    localHaveCriminalRecord ?? false,
                                crimes:
                                    (localHaveCriminalRecord ?? false)
                                        ? localCrimeList
                                        : [],
                                appliedDate: kycData.appliedDate,
                              );

                          final msg = await KycController()
                              .updateKycApplication(updatedKyc);
                          setState(() {
                            isLoading = false;
                          });
                          if (msg) {
                            showCustomSnackBar(
                              context: context,
                              message: "Due Diligence Updated successfully",
                              backgroundColor: AppColors().green,
                            );
                            ref.invalidate(getKycData);
                          } else {
                            showCustomSnackBar(
                              context: context,
                              message: "Failed to update Due Diligence",
                              backgroundColor: AppColors().red,
                            );
                          }
                        },
                        isLoading: isLoading,
                        text: "Save Changes",
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
