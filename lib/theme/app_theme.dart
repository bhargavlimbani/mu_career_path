import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF01A6BA); // teal
  static const Color secondaryColor = Colors.white;    // white
  static const Color blackColor = Colors.black;        // black

  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
    Color? hintTextColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: secondaryColor.withOpacity(0.1),
      hintStyle: TextStyle(color: hintTextColor ?? Colors.grey[500]),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: primaryColor.withOpacity(0.5), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  static ButtonStyle elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: primaryColor.withOpacity(0.5),
      elevation: 6,
    );
  }

  static const TextStyle buttonText = TextStyle(
    color: secondaryColor,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle linkText = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );
}
