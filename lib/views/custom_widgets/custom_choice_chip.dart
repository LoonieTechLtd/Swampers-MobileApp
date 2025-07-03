import 'package:flutter/material.dart';

/// A horizontal scrollable list of sport choice chips.
class CustomChoiceChip extends StatefulWidget {
  final void Function(String sport)? onWorkSelected;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final bool isStacked;
  const CustomChoiceChip({
    super.key,
    this.onWorkSelected,
    this.iconSize = 18.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.isStacked = false,
  });

  @override
  State<CustomChoiceChip> createState() => _CustomChoiceChipState();
}

class _CustomChoiceChipState extends State<CustomChoiceChip> {
  static const works = [
    _Sport("All Works", Icons.circle),
    _Sport("Warehouse Associates", Icons.warehouse),
    _Sport("Construction Labours", Icons.construction),
    _Sport("Factory Workers", Icons.factory),
    _Sport("Handy Man", Icons.handshake),
    _Sport("Cleaners", Icons.cleaning_services),
    _Sport("Mover", Icons.move_up),
    _Sport("General Workers", Icons.home),
    _Sport("Restaurent Services", Icons.restaurant_menu),
  ];

  int _selectedIndex = 0;
  String result = '';

  @override
  Widget build(BuildContext context) {
    final chips =
        works.asMap().entries.map((entry) {
          final index = entry.key;
          final sport = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              right: widget.isStacked ? 0 : 8.0,
              bottom: widget.isStacked ? 2.0 : 0,
            ),
            child: ChoiceChip(
              avatar: Icon(
                sport.icon,
                size: widget.iconSize,
                color: _selectedIndex == index ? Colors.white : Colors.black,
              ),
              showCheckmark: false,
              label: Text(sport.name),
              selected: _selectedIndex == index,
              onSelected:
                  (selected) => _handleSelection(selected, index, sport.name),
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: _selectedIndex == index ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.grey[200],
            ),
          );
        }).toList();

    return widget.isStacked
        ? Padding(
          padding: widget.padding,
          child: Wrap(spacing: 8.0, runSpacing: 0.0, children: chips),
        )
        : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(padding: widget.padding, child: Row(children: chips)),
        );
  }

  void _handleSelection(bool selected, int index, String sport) {
    if (selected) {
      setState(() => _selectedIndex = index);
      widget.onWorkSelected?.call(sport);
      result = works[index].toString();
    }
  }
}

class _Sport {
  final String name;
  final IconData icon;

  const _Sport(this.name, this.icon);
}
