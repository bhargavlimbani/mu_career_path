import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Core color definitions
  static const Color primaryColor = Color(0xFF01A6BA); // teal
  static const Color secondaryColor = Colors.white;    // white
  static const Color blackColor = Colors.black;        // black

  // ✅ Backward compatibility for old code references
  static const Color primary = primaryColor;
  static const Color secondary = secondaryColor;
  static const Color textColor = blackColor;

  // 🧱 Input field styling
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
    Color? hintTextColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: primaryColor),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: secondaryColor.withOpacity(0.1),
      hintStyle: TextStyle(color: hintTextColor ?? Colors.grey[500]),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  // 🧱 Elevated button styling
  static ButtonStyle elevatedButtonStyle({double radius = 16}) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      shadowColor: primaryColor.withOpacity(0.5),
      elevation: 6,
    );
  }

  // ✍️ Button text style
  static const TextStyle buttonText = TextStyle(
    color: secondaryColor,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // ✍️ Link text style
  static const TextStyle linkText = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );
}
