import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/views/custom_widgets/custom_textfield.dart';

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
    this.validator,
  });

  final TextEditingController controller;
  final String title;
  final String hintText;
  final TextInputType? inputType;
  final bool enabled;
  final VoidCallback? onTap;
  final int? maxLines;
  final String? Function(String?)? validator;

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
            validator:
                validator ??
                (value) {
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
