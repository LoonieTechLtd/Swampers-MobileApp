// lib/views/custom_widgets/day_range_selector.dart

import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

class DayRangeSelector extends StatelessWidget {
  final DateTimeRange? selectedDayRange;
  final String? dayRangeStr;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const DayRangeSelector({
    super.key,
    required this.selectedDayRange,
    required this.dayRangeStr,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Days", style: CustomTextStyles.h5),
          Container(
            padding: const EdgeInsets.only(left: 12),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black12,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: dayRangeStr == null
                  ? Text(
                      "Jan 2 to Feb 14",
                      style: CustomTextStyles.description
                          .copyWith(color: Colors.black38),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueGrey),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(dayRangeStr!),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onClear,
                            child: const Icon(
                              Icons.cancel_outlined,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
