import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String hintText;

  final Color? color;
  const CustomSearchBar({
    super.key,
    this.color,
    required this.searchController, required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: Icon(FeatherIcons.search),
          fillColor: color ?? Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 1, color: Colors.black38),
          ),
        ),
      ),
    );
  }
}
