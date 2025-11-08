import 'package:flutter/material.dart';
import '../data/local_data.dart';
import '../theme/app_theme.dart';

class ViewCompaniesScreen extends StatelessWidget {
  final ld = LocalData();

  ViewCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var user = ld.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Companies'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: ld.companies.length,
          itemBuilder: (context, i) {
            var c = ld.companies[i];
            bool show = true;

            // Check if company should be shown for unplaced students
            if (user != null) {
              if (!c.allowedForUnplaced) show = false;
            }

            if (!show) return const SizedBox.shrink();

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                title: Text(
                  c.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  c.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: const Icon(Icons.business, color: AppTheme.primaryColor),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
