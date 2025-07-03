import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors().primaryColor),
      height: MediaQuery.of(context).size.height * 0.066,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Image.asset("assets/images/company_logo.png"),
          ),
          Text(
            "Swamper Solutions",
            textAlign: TextAlign.center,
            style: CustomTextStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(FeatherIcons.phone, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
