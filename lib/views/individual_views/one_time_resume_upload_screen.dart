import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/user_controller.dart';
import 'package:swamper_solution/views/custom_widgets/custom_button.dart';

class OneTimeResumeUploadScreen extends StatefulWidget {
  const OneTimeResumeUploadScreen({super.key});
  @override
  State<OneTimeResumeUploadScreen> createState() =>
      _OneTimeResumeUploadScreenState();
}

class _OneTimeResumeUploadScreenState extends State<OneTimeResumeUploadScreen> {
  final UserController _userController = UserController();
  XFile? selectedResume;
  bool _isUploading = false;
  String? _uploadedResumeUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingResume();
  }

  Future<bool> _checkExistingResume() async {
    try {
      final existingResumeUrl = await _userController.getOneTimeResumeUrl();
      debugPrint("Existing URL: $existingResumeUrl");
      setState(() {
        _uploadedResumeUrl = existingResumeUrl;
        _isLoading = false;
      });
      if (existingResumeUrl == null || existingResumeUrl.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      return false;
    }
  }

  Future<void> _selectAndUploadResume() async {
    try {
      // Show loading state
      setState(() {
        _isUploading = true;
      });

      // Pick PDF file
      final selectedFile = await _userController.pickPDFFile();

      if (selectedFile == null) {
        // User cancelled file selection
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Validate file size (optional - you can set a limit, e.g., 10MB)
      final fileSize = await selectedFile.length();
      const maxSizeInBytes = 10 * 1024 * 1024; // 10MB

      if (fileSize > maxSizeInBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size should be less than 10MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isUploading = false;
        });
        return;
      }

      setState(() {
        selectedResume = selectedFile;
      });

      // Upload resume
      final downloadUrl = await _userController.addOneTimeResume(selectedFile);

      if (downloadUrl.isNotEmpty) {
        setState(() {
          _uploadedResumeUrl = downloadUrl;
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resume uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isUploading = false;
          selectedResume = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload resume. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        selectedResume = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Upload Your Resume Once',
                style: CustomTextStyles.h2.copyWith(
                  color: AppColors().primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Save time by uploading your resume just once. You won\'t need to upload it again for future applications.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Supported format: PDF only',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 24),
              (_uploadedResumeUrl != null && _uploadedResumeUrl!.isNotEmpty)
                  ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green.shade50,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resume already uploaded',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'You can upload a new resume to replace the current one.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  : Text("No resume added"),

              const SizedBox(height: 24),

              const Spacer(),

              CustomButton(
                backgroundColor: AppColors().primaryColor,
                onPressed: () {
                  _selectAndUploadResume();
                },
                isLoading: _isUploading,

                text:
                    (_uploadedResumeUrl != null &&
                            _uploadedResumeUrl!.isNotEmpty)
                        ? "Update your resume"
                        : "Select a resume",
                textColor: AppColors().white,
              ),

              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}
