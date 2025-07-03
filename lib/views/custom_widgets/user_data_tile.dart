import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

class UserDataTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const UserDataTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CustomTextStyles.h4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.06,
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: Colors.black38),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(value, style: CustomTextStyles.description),
              Spacer(),
              Icon(icon),
            ],
          ),
        ),
      ],
    );
  }
}
