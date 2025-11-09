import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DataScienceAIExploreScreen extends StatelessWidget {
  const DataScienceAIExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text(
          '🧠 Data Science & AI',
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
              "Data Science and Artificial Intelligence involve analyzing data, building predictive models, and automating decision-making."),
          _section("🛠️ Required Skills", [
            "Python / R Programming",
            "Machine Learning & Deep Learning",
            "Statistics & Data Analysis",
            "Pandas, NumPy, Matplotlib, TensorFlow",
            "SQL / Data Visualization Tools"
          ]),
          _section("🏢 Top Companies",
              ["Google AI", "NVIDIA", "IBM", "TCS", "Amazon AWS"]),
          _section("🎯 Career Roles", [
            "Data Analyst",
            "Machine Learning Engineer",
            "AI Researcher",
            "Data Engineer"
          ]),
          _section("📚 Learning Resources", [
            "Kaggle Competitions",
            "Coursera AI & ML Specialization",
            "YouTube: Krish Naik, Simplilearn"
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