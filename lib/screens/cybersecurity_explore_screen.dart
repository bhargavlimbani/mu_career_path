import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CyberSecurityExploreScreen extends StatelessWidget {
  const CyberSecurityExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text(
          '🔒 Cybersecurity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section("📘 Overview",
            "Cybersecurity protects systems and networks from digital attacks, ensuring data privacy and integrity."),
        _section("🛠️ Required Skills", [
          "Networking & Firewalls",
          "Linux & Command Line",
          "Ethical Hacking Tools (Burp Suite, Metasploit)",
          "Security Analysis & Risk Assessment",
          "Python for Security"
        ]),
        _section("🏢 Top Companies",
            ["Cisco", "Palo Alto Networks", "IBM", "CrowdStrike", "Google"]),
        _section("🎯 Career Roles",
            ["Security Analyst", "Penetration Tester", "SOC Engineer", "Forensics Expert"]),
        _section("📚 Learning Resources", [
          "Cybrary / TryHackMe",
          "Coursera – Cybersecurity Specialization",
          "YouTube: NetworkChuck, HackerSploit"
        ]),
      ]),
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