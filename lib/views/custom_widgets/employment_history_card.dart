import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

class EmploymentHistoryCard extends StatelessWidget {
  final String title;
  final String location;
  final String hourlyIncome;
  final String startedDate;
  final String noOfDays;
  const EmploymentHistoryCard({
    super.key,
    required this.title,
    required this.location,
    required this.hourlyIncome,
    required this.startedDate, required this.noOfDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: BoxDecoration(
        border: Border.all(width: 0.6, color: Colors.black45),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    
      width: MediaQuery.of(context).size.width,
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: CustomTextStyles.h4),
              Spacer(),
              Text(
                startedDate,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              
              Icon(FeatherIcons.mapPin, size: 16),
              Text(location, style: CustomTextStyles.description),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              Icon(FeatherIcons.calendar, size: 16),
              Text("$noOfDays Days", style: CustomTextStyles.description),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              Icon(FeatherIcons.dollarSign, size: 16),
              Text("$hourlyIncome / hr", style: CustomTextStyles.description),
            ],
          ),
        ],
      ),
    );
  }
}
