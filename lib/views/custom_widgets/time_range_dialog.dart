// Improved TimeRangeDialog with proper width and overflow fixes
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:swamper_solution/consts/app_colors.dart';

class TimeRangeDialog extends StatefulWidget {
  final List<String> initialTimeRanges;
  final Function(List<String>) onTimeRangesSelected;

  const TimeRangeDialog({
    Key? key,
    required this.initialTimeRanges,
    required this.onTimeRangesSelected,
  }) : super(key: key);

  @override
  _TimeRangeDialogState createState() => _TimeRangeDialogState();
}

class _TimeRangeDialogState extends State<TimeRangeDialog> {
  List<TimeRangeItem> timeRanges = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing time ranges or add one empty range
    if (widget.initialTimeRanges.isNotEmpty) {
      for (String range in widget.initialTimeRanges) {
        var item = TimeRangeItem();
        final parts = range.split(' To ');
        if (parts.length == 2) {
          item.startTime = _parseTimeOfDay(parts[0]);
          item.endTime = _parseTimeOfDay(parts[1]);
        }
        timeRanges.add(item);
      }
    } else {
      timeRanges.add(TimeRangeItem());
    }
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    try {
      // Remove extra spaces and normalize
      timeString = timeString.trim();

      // Handle 12-hour format with AM/PM
      bool isPM = timeString.toUpperCase().contains('PM');
      bool isAM = timeString.toUpperCase().contains('AM');

      // Extract time part (remove AM/PM)
      String timePart = timeString.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = timePart.split(':');

      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        // Convert to 24-hour format
        if (isPM && hour != 12) {
          hour += 12;
        } else if (isAM && hour == 12) {
          hour = 0;
        }

        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Return default time if parsing fails
    }
    return const TimeOfDay(hour: 9, minute: 0); // Default 9:00 AM
  }

  void _addTimeRange() {
    setState(() {
      timeRanges.add(TimeRangeItem());
    });
  }

  void _removeTimeRange(int index) {
    if (timeRanges.length > 1) {
      setState(() {
        timeRanges.removeAt(index);
      });
    }
  }

  bool _validateAndSave() {
    List<String> validRanges = [];

    for (int i = 0; i < timeRanges.length; i++) {
      TimeOfDay startTime = timeRanges[i].startTime;
      TimeOfDay endTime = timeRanges[i].endTime;

      // Validate duration (2-6 hours)
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;
      int duration = endMinutes - startMinutes;

      if (duration < 0) duration += 24 * 60;

      if (duration > 360 || duration < 120) {
        _showErrorDialog(
          "Shift must be less than 6 hours and more than 2 hours.",
        );
        return false;
      }

      // Format time in 12-hour format for saving
      String timeRange =
          '${_formatTime12Hour(startTime)} To ${_formatTime12Hour(endTime)}';
      validRanges.add(timeRange);
    }

    widget.onTimeRangesSelected(validRanges);
    return true;
  }

  // Convert 24-hour TimeOfDay to 12-hour format string with AM/PM
  String _formatTime12Hour(TimeOfDay time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert to 12-hour format
    if (hour == 0) {
      hour = 12; // Midnight
    } else if (hour > 12) {
      hour -= 12; // Afternoon/Evening
    }

    String hourStr = hour.toString();
    String minuteStr = minute.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr $period';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Invalid Input"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK", style: TextStyle(color: AppColors().red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: screenWidth * 0.92, // 92% of screen width
        constraints: BoxConstraints(
          maxWidth: 500, // Maximum width for larger screens
          maxHeight: screenHeight * 0.8, // Maximum 80% of screen height
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: const Text(
                "Select Time Ranges",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  children: [
                    const Text(
                      "Scroll to select start and end times for each shift",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Time ranges list
                    ...timeRanges.asMap().entries.map((entry) {
                      int index = entry.key;
                      TimeRangeItem item = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: Column(
                          children: [
                            // Header row with shift label and delete button
                            Row(
                              children: [
                                Text(
                                  "Shift ${index + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                if (timeRanges.length > 1)
                                  IconButton(
                                    onPressed: () => _removeTimeRange(index),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 22,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Time pickers row - fixed overflow
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  children: [
                                    // Start Time Picker
                                    Expanded(
                                      flex: 5,
                                      child: TimePickerField(
                                        label: "Start Time",
                                        time: item.startTime,
                                        onTimeChanged: (newTime) {
                                          setState(() {
                                            item.startTime = newTime;
                                          });
                                        },
                                      ),
                                    ),

                                    // "TO" indicator
                                    Container(
                                      width: 40,
                                      padding: const EdgeInsets.only(top: 20),
                                      child: const Text(
                                        "TO",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                    // End Time Picker
                                    Expanded(
                                      flex: 5,
                                      child: TimePickerField(
                                        label: "End Time",
                                        time: item.endTime,
                                        onTimeChanged: (newTime) {
                                          setState(() {
                                            item.endTime = newTime;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    // Add another time range button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addTimeRange,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text("Add Another Time Range"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_validateAndSave()) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text("Save", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeRangeItem {
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0); // Default 9:00 AM
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0); // Default 5:00 PM
}

class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final Function(TimeOfDay) onTimeChanged;

  const TimePickerField({
    Key? key,
    required this.label,
    required this.time,
    required this.onTimeChanged,
  }) : super(key: key);

  // Convert 24-hour TimeOfDay to 12-hour format string with AM/PM
  String _formatTime12Hour(TimeOfDay time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert to 12-hour format
    if (hour == 0) {
      hour = 12; // Midnight
    } else if (hour > 12) {
      hour -= 12; // Afternoon/Evening
    }

    String hourStr = hour.toString();
    String minuteStr = minute.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showTimePicker(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatTime12Hour(time),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return IOSStyleTimePicker(
          initialTime: time,
          onTimeChanged: onTimeChanged,
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

class IOSStyleTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;

  const IOSStyleTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  _IOSStyleTimePickerState createState() => _IOSStyleTimePickerState();
}

class _IOSStyleTimePickerState extends State<IOSStyleTimePicker> {
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController periodController;

  int selectedHour = 12;
  int selectedMinute = 0;
  int selectedPeriod = 0;

  @override
  void initState() {
    super.initState();

    // Convert 24-hour format to 12-hour format for display
    int hour24 = widget.initialTime.hour;
    selectedPeriod = hour24 >= 12 ? 1 : 0;
    selectedHour = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    selectedMinute = widget.initialTime.minute;

    hourController = FixedExtentScrollController(initialItem: selectedHour - 1);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    periodController = FixedExtentScrollController(initialItem: selectedPeriod);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    periodController.dispose();
    super.dispose();
  }

  TimeOfDay get currentTime {
    int hour24 = selectedHour;
    if (selectedPeriod == 1 && selectedHour != 12) {
      hour24 += 12;
    } else if (selectedPeriod == 0 && selectedHour == 12) {
      hour24 = 0;
    }
    return TimeOfDay(hour: hour24, minute: selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
              const Text(
                "Select Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  widget.onTimeChanged(currentTime);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Time Picker Wheels
          Expanded(
            child: Row(
              children: [
                // Hour wheel
                Expanded(
                  flex: 3,
                  child: CupertinoPicker(
                    scrollController: hourController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedHour = index + 1;
                      });
                    },
                    children: List.generate(12, (index) {
                      return Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    }),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ':',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                // Minute wheel
                Expanded(
                  flex: 3,
                  child: CupertinoPicker(
                    scrollController: minuteController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedMinute = index;
                      });
                    },
                    children: List.generate(60, (index) {
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(width: 16),

                // AM/PM wheel
                Expanded(
                  flex: 2,
                  child: CupertinoPicker(
                    scrollController: periodController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedPeriod = index;
                      });
                    },
                    children: const [
                      Center(child: Text('AM', style: TextStyle(fontSize: 20))),
                      Center(child: Text('PM', style: TextStyle(fontSize: 20))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Selected time display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Selected: ${currentTime.format(context)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
