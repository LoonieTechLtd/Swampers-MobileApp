import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final String hintText;
  final String? labelText;
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
    this.labelText,
    this.suffixIcon,
    required this.controller,
    this.onPressedSuffix,
    required this.obscureText,
    required this.textInputType,
    this.validator,
    this.enabled,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String? _composeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "${widget.hintText} cannot be empty";
    }

    if (widget.validator != null) {
      return widget.validator!(value);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show field name when focused or when there's text
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: (_isFocused || widget.controller.text.isNotEmpty) ? 20 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity:
                (_isFocused || widget.controller.text.isNotEmpty) ? 1.0 : 0.0,
            child: Text(
              widget.labelText ?? widget.hintText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _isFocused ? Colors.blue : Colors.black54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          focusNode: _focusNode,
          validator: _composeValidator,
          keyboardType: widget.textInputType,
          obscureText: widget.obscureText,
          enabled: widget.enabled ?? true,
          controller: widget.controller,
          decoration: InputDecoration(
            suffixIcon:
                widget.suffixIcon != null
                    ? IconButton(
                      onPressed: widget.onPressedSuffix,
                      icon: widget.suffixIcon!,
                    )
                    : null,
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.black38),
            filled: true,
            fillColor:
                _isFocused ? Colors.blue.withOpacity(0.05) : Colors.black12,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 2, color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
