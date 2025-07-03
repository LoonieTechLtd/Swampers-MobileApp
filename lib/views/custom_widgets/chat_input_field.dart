import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final bool isEnabled;
  final Color primaryColor;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.isEnabled,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type your Message....",
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.black12,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isEnabled ? onSendPressed : null,
                  icon: Icon(Icons.send, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
