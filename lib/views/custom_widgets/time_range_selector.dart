// lib/views/custom_widgets/time_range_selector.dart

import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/views/custom_widgets/time_range_dialog.dart';

class TimeRangeSelector extends StatelessWidget {
  final List<String> timeRanges;
  final Function(List<String>) onRangesUpdated;

  const TimeRangeSelector({
    super.key,
    required this.timeRanges,
    required this.onRangesUpdated,
  });

  Future<void> _selectTimeRanges(BuildContext context) async {
    List<String> tempTimeRanges = [...timeRanges];

    await showDialog(
      context: context,
      builder: (context) => TimeRangeDialog(
        initialTimeRanges: tempTimeRanges,
        onTimeRangesSelected: (List<String> selectedRanges) {
          onRangesUpdated(selectedRanges);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectTimeRanges(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Shifts", style: CustomTextStyles.h5),
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
              child: timeRanges.isEmpty
                  ? Text(
                      "01:30 To 05:30",
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.black38,
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          timeRanges.length,
                          (index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blueGrey),
                              ),
                              child: Row(
                                children: [
                                  Text(timeRanges[index]),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      final updatedList = [...timeRanges];
                                      updatedList.removeAt(index);
                                      onRangesUpdated(updatedList);
                                    },
                                    child: const Icon(
                                      Icons.cancel_outlined,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
