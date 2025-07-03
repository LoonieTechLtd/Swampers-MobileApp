import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

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
