import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme: const IconThemeData(
        color: Color.fromARGB(255, 169, 155, 149),
      ),
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        color: Color.fromARGB(255, 0, 4, 217),
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 10,
        color: Colors.black,
      ),
      onTap: onTap,
      items: List.generate(items.length, (index) {
        final item = items[index];
        return BottomNavigationBarItem(
          label: item.label,
          icon:
              index == currentIndex
                  ? Container(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 6,
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 4, 217),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item.icon,
                  )
                  : item.icon,
        );
      }),
    );
  }
}
