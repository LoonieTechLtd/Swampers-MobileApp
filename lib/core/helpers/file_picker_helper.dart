import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerHelper {
  final ImagePicker _picker = ImagePicker();
  XFile? permitDoc;
  XFile? govIdDoc;
  XFile? voidChequeDoc;

  // Document files for PDF/DOC uploads
  File? permitDocFile;
  File? govIdDocFile;
  File? voidChequeDocFile;
  String? permitDocFileName;
  String? govIdDocFileName;
  String? voidChequeDocFileName;

  // Callback function to notify parent widget of state changes
  final VoidCallback? onStateChanged;

  // Constructor
  FilePickerHelper({this.onStateChanged});

  // to pick doc images
  Future<void> pickImage(String docType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
      );
      if (image != null) {
        if (docType == "workPermit") {
          permitDoc = image;
        }
        if (docType == "govId") {
          govIdDoc = image;
        }
        if (docType == "voidCheque") {
          voidChequeDoc = image;
        }
        // Notify parent widget of state change
        onStateChanged?.call();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Pick document method
  Future<void> pickDocument(String docType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Clear image when document is selected
        if (docType == "workPermit") {
          permitDoc = null;
          permitDocFile = file;
          permitDocFileName = fileName;
        }
        if (docType == "govId") {
          govIdDoc = null;
          govIdDocFile = file;
          govIdDocFileName = fileName;
        }
        if (docType == "voidCheque") {
          voidChequeDoc = null;
          voidChequeDocFile = file;
          voidChequeDocFileName = fileName;
        }
        // Notify parent widget of state change
        onStateChanged?.call();
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
    }
  }

  void showUploadOptions(String docType, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Upload Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.photo_camera, color: Colors.green),
                  title: Text('Upload Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(docType);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.description, color: Colors.blue),
                  title: Text('Upload Document (PDF, DOC)'),
                  onTap: () {
                    Navigator.pop(context);
                    pickDocument(docType);
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
