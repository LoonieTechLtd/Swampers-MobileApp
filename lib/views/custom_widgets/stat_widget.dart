import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

class StatWidget extends StatelessWidget {
  final String data;
  final String label;
  const StatWidget({super.key, required this.data, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 4,
      children: [
        Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 12),
          constraints: BoxConstraints(minWidth: 78),
          decoration: BoxDecoration(
            
            borderRadius: BorderRadius.circular(40),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              data,
              style: GoogleFonts.audiowide(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Text(
          label,
          style: CustomTextStyles.description.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
