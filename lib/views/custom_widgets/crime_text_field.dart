import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/app_colors.dart';

class CrimeTextField extends StatefulWidget {
  final String text;
  final String? labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CrimeTextField({
    super.key,
    required this.controller,
    required this.text,
    this.labelText,
    this.validator,
  });

  @override
  State<CrimeTextField> createState() => _CrimeTextFieldState();
}

class _CrimeTextFieldState extends State<CrimeTextField> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: (_isFocused || widget.controller.text.isNotEmpty) ? 20 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity:
                (_isFocused || widget.controller.text.isNotEmpty) ? 1.0 : 0.0,
            child: Text(
              widget.labelText ?? widget.text,
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
          validator: widget.validator,
          focusNode: _focusNode,
          controller: widget.controller,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                _isFocused ? Colors.blue.withOpacity(0.05) : AppColors().white,
            hintText: widget.text,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 2, color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
