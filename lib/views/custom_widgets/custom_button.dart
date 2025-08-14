import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/app_colors.dart';

class CustomButton extends StatelessWidget {
  final Color backgroundColor;
  final VoidCallback onPressed;
  final bool? isLoading;
  final String text;
  final IconData? icon;
  final Color textColor;
  final bool? haveBorder;
  final Color? borderColor;
  final double? borderWidth;
  const CustomButton({
    super.key,
    required this.backgroundColor,
    required this.onPressed,
    this.isLoading,
    required this.text,
    this.icon,
    required this.textColor,
    this.haveBorder,
    this.borderColor,
    this.borderWidth
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: (isLoading ?? false) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side:
                (haveBorder ?? false)
                    ? BorderSide(
                      color: borderColor ?? AppColors().primaryColor,
                      width: borderWidth??1,
                    )
                    : BorderSide.none,
          ),

          elevation: 0,
          backgroundColor: backgroundColor,
        ),
        child:
            (isLoading ?? false)
                ? CircularProgressIndicator(color: Colors.white)
                : Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }
}
