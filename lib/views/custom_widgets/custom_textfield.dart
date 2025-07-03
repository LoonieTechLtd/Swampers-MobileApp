import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String hintText;
  final Icon? suffixIcon;
  final VoidCallback? onPressedSuffix;
  final TextEditingController controller;
  final bool obscureText;
  final bool? enabled;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  
  const CustomTextfield({
    super.key,
    required this.hintText,
    this.suffixIcon,
    required this.controller,
    this.onPressedSuffix,
    required this.obscureText,
    required this.textInputType,
    this.validator,
    this.enabled,
  });

  String? _composeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "$hintText cannot be empty";
    }
    
    if (validator != null) {
      return validator!(value);
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: _composeValidator,
      keyboardType: textInputType,
      obscureText: obscureText,
      enabled: enabled ?? true,
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon != null
            ? IconButton(onPressed: onPressedSuffix, icon: suffixIcon!)
            : null,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38),
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
    );
  }
}