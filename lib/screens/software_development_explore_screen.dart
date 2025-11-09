import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SoftwareDevelopmentExploreScreen extends StatelessWidget {
  const SoftwareDevelopmentExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text(
          '💻 Software Development',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("📘 Overview"),
            _text(
                "Software Development involves designing, coding, testing, and maintaining applications for mobile, web, and systems."),

            _sectionTitle("🛠️ Required Skills"),
            _bulletPoints([
              "Programming (C, C++, Java, Python, Dart)",
              "Frontend: Flutter, React, HTML/CSS/JS",
              "Backend: Node.js, Firebase, PHP, MySQL",
              "Version Control (Git/GitHub)",
              "Problem Solving & DSA",
            ]),

            _sectionTitle("🏢 Top Companies"),
            _bulletPoints(["TCS", "Infosys", "Wipro", "Amazon", "Google", "Microsoft"]),

            _sectionTitle("🎯 Career Roles"),
            _bulletPoints([
              "App Developer",
              "Web Developer",
              "Software Engineer",
              "Backend Developer",
              "Full Stack Developer",
            ]),

            _sectionTitle("📚 Learning Resources"),
            _bulletPoints([
              "Udemy / Coursera Courses",
              "YouTube: CodeWithHarry, freeCodeCamp",
              "LeetCode & HackerRank practice",
            ]),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text("Explore More Resources"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor)),
  );

  Widget _text(String text) => Text(text,
      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4));

  Widget _bulletPoints(List<String> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items
        .map((e) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text("• $e",
          style:
          const TextStyle(fontSize: 15, color: Colors.black87)),
    ))
        .toList(),
  );
}