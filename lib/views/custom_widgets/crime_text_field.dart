import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/app_colors.dart';

class CrimeTextField extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  const CrimeTextField({
    super.key,
    required this.controller,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors().white,
        hintText: text,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
