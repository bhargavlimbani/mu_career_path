import 'package:flutter/material.dart';
import 'package:mu_career_pat_offline/theme/app_theme.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🧩 Lists of companies
    final List<String> softwareCompanies = [
      "TCS",
      "INFOSYS",
      "WIPRO",
      "AMAZON",
      "FINETECH",
    ];

    final List<String> hardwareCompanies = [
      "ADANI",
      "INTEL",
      "DELL",
      "HP",
      "SAMSUNG",
    ];

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,

      // ✅ Beautiful rounded AppBar
      appBar: AppBar(
        title: const Text(
          'Companies',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        centerTitle: true,
      ),

      // ✅ Scrollable content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧩 Software Companies Section
            const Text(
              "Software Companies",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: softwareCompanies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return _buildCompanyCard(softwareCompanies[index]);
              },
            ),

            const SizedBox(height: 25),

            // ⚙️ Hardware Companies Section
            const Text(
              "Hardware Companies",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hardwareCompanies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return _buildCompanyCard(hardwareCompanies[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Reusable Card Builder
  Widget _buildCompanyCard(String name) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}