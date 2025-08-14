import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String title;
  final bool isSinExpiry;

  const DatePickerBottomSheet({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.minDate,
    this.maxDate,
    required this.title,
    required this.isSinExpiry
  });

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;

  late List<int> years;
  late List<int> days;

  static const List<int> _months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late PageController _yearController;
  late PageController _monthController;
  late PageController _dayController;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _initializeControllers();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final minYear = widget.minDate?.year ?? 1900;
    final maxYear = widget.isSinExpiry?widget.maxDate?.year ?? 2040:widget.maxDate?.year ?? now.year;

    years = List.generate(maxYear - minYear + 1, (index) => minYear + index);

    selectedYear = widget.initialDate?.year ?? now.year;
    selectedMonth = widget.initialDate?.month ?? now.month;
    selectedDay = widget.initialDate?.day ?? now.day;

    _updateDays();
  }

  void _initializeControllers() {
    _yearController = PageController(
      initialPage: years.indexOf(selectedYear),
      viewportFraction: 0.3,
    );
    _monthController = PageController(
      initialPage: _months.indexOf(selectedMonth),
      viewportFraction: 0.3,
    );
    _dayController = PageController(
      initialPage: days.indexOf(selectedDay),
      viewportFraction: 0.3,
    );
  }

  void _updateDays() {
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    days = List.generate(daysInMonth, (index) => index + 1);

    if (selectedDay > daysInMonth) {
      selectedDay = daysInMonth;
    }
  }

  void _onYearChanged(int index) {
    setState(() {
      selectedYear = years[index];
      _updateDays();
    });

    // Update day controller if needed
    if (!days.contains(selectedDay)) {
      _dayController.animateToPage(
        days.indexOf(selectedDay),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onMonthChanged(int index) {
    setState(() {
      selectedMonth = _months[index];
      _updateDays();
    });

    // Update day controller if needed
    if (!days.contains(selectedDay)) {
      _dayController.animateToPage(
        days.indexOf(selectedDay),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onDayChanged(int index) {
    setState(() {
      selectedDay = days[index];
    });
  }

  Widget _buildPickerColumn({
    required String title,
    required List<dynamic> items,
    required PageController controller,
    required Function(int) onChanged,
    required dynamic selectedValue,
    bool showMonthNames = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: controller,
              scrollDirection: Axis.vertical,
              onPageChanged: onChanged,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selectedValue;

                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 24 : 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[600],
                    ),
                    child: Text(
                      showMonthNames && index < _monthNames.length
                          ? _monthNames[index]
                          : item.toString().padLeft(2, '0'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.6;
    final pickerHeight = (maxHeight * 0.4).clamp(150.0, 200.0);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: CustomTextStyles.title),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Date display
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedDay.toString().padLeft(2, '0')} ${_monthNames[selectedMonth - 1]} $selectedYear',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Date pickers
              SizedBox(
                height: pickerHeight,
                child: Row(
                  children: [
                    _buildPickerColumn(
                      title: 'Year',
                      items: years,
                      controller: _yearController,
                      onChanged: _onYearChanged,
                      selectedValue: selectedYear,
                    ),
                    _buildPickerColumn(
                      title: 'Month',
                      items: _months,
                      controller: _monthController,
                      onChanged: _onMonthChanged,
                      selectedValue: selectedMonth,
                      showMonthNames: true,
                    ),
                    _buildPickerColumn(
                      title: 'Day',
                      items: days,
                      controller: _dayController,
                      onChanged: _onDayChanged,
                      selectedValue: selectedDay,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final selectedDate = DateTime(
                      selectedYear,
                      selectedMonth,
                      selectedDay,
                    );
                    widget.onDateSelected(selectedDate);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }
}
