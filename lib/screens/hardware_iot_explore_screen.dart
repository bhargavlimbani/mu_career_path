import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HardwareIoTExploreScreen extends StatelessWidget {
  const HardwareIoTExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text(
          '⚙️ Hardware & IoT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _section("📘 Overview",
              "Hardware and IoT combine electronics, sensors, and networking to build smart, connected systems."),
          _section("🛠️ Required Skills", [
            "Arduino / Raspberry Pi Programming",
            "Embedded C / C++",
            "Circuit Design & Sensors",
            "IoT Protocols (MQTT, HTTP)",
            "Cloud Integration (AWS IoT, Blynk)"
          ]),
          _section("🏢 Top Companies",
              ["Intel", "Bosch", "Samsung", "Siemens", "Honeywell"]),
          _section("🎯 Career Roles", [
            "Embedded Engineer",
            "IoT Developer",
            "Hardware Design Engineer",
            "Automation Engineer"
          ]),
          _section("📚 Learning Resources", [
            "YouTube: GreatScott!, Techiesms",
            "Udemy: IoT & Embedded Systems Courses",
            "MIT OpenCourseWare – Electronics"
          ]),
        ]),
      ),
    );
  }

  Widget _section(String title, dynamic content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor)),
        const SizedBox(height: 8),
        if (content is List)
          ...content.map((e) => Text("• $e",
              style: const TextStyle(fontSize: 15, color: Colors.black87))),
        if (content is String)
          Text(content,
              style:
              const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)),
      ]),
    );
  }
}