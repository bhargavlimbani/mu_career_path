import 'package:flutter/material.dart';
import '../data/local_data.dart';

class ViewCompaniesScreen extends StatelessWidget {
  final ld = LocalData();

  ViewCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var user = ld.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text('Companies')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: ld.companies.length,
          itemBuilder: (context, i) {
            var c = ld.companies[i];
            bool show = true;
            if (user != null && user.role == (user.email.endsWith('@marwadiuniversity.ac.in') ? user.role : user.role)) {
              if (!c.allowedForUnplaced) show = false;
            }
            if (!show) return SizedBox.shrink();
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(c.name),
                subtitle: Text(c.description),
              ),
            );
          },
        ),
      ),
    );
  }
}
