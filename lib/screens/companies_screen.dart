import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mu_career_pat_offline/theme/app_theme.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});


  List<Map<String, dynamic>> getSoftwareCompanies() {
    return [
      {
        'name': 'TCS',
        'desc': 'Leading IT services, consulting and business solutions provider.',
        'criteria': 'CGPA 6.0+, No backlogs, Good communication skills',
        'placed': '120 Students',
        'link': 'https://www.tcs.com/careers',
        'hiringMonth': 'January 2025',
      },
      {
        'name': 'AMAZON',
        'desc': 'World’s largest e-commerce and cloud computing company.',
        'criteria': 'CGPA 7.5+, Strong problem solving and DSA skills',
        'placed': '80 Students',
        'link': 'https://www.amazon.jobs',
        'hiringMonth': 'February 2025',
      },
      {
        'name': 'INFOSYS',
        'desc': 'Top Indian IT firm offering software and digital services worldwide.',
        'criteria': 'CGPA 6.5+, Basic programming knowledge',
        'placed': '150 Students',
        'link': 'https://www.infosys.com/careers',
        'hiringMonth': 'March 2025',
      },
      {
        'name': 'FINTECH',
        'desc': 'A growing startup specializing in online payment and finance software.',
        'criteria': 'CGPA 7.0+, Interest in finance tech',
        'placed': '30 Students',
        'link': 'https://www.fintech.com',
        'hiringMonth': 'April 2025',
      },
      {
        'name': 'CASTAI',
        'desc': 'Cloud optimization platform for Kubernetes applications.',
        'criteria': 'CGPA 7.0+, Cloud and DevOps fundamentals',
        'placed': '12 Students',
        'link': 'https://www.cast.ai',
        'hiringMonth': 'May 2025',
      },
      {
        'name': 'FLIPKART',
        'desc': 'E-commerce giant offering digital retail and logistics solutions.',
        'criteria': 'CGPA 7.5+, Competitive programming, DSA',
        'placed': '60 Students',
        'link': 'https://www.flipkartcareers.com',
        'hiringMonth': 'June 2025',
      },
      {
        'name': 'WIPRO',
        'desc': 'Global leader in IT, consulting, and business process services.',
        'criteria': 'CGPA 6.0+, No active backlogs',
        'placed': '140 Students',
        'link': 'https://careers.wipro.com',
        'hiringMonth': 'July 2025',
      },
      {
        'name': 'RTCAMP',
        'desc': 'A WordPress and web engineering agency delivering enterprise solutions.',
        'criteria': 'CGPA 6.5+, Web development basics',
        'placed': '25 Students',
        'link': 'https://rtcamp.com/careers',
        'hiringMonth': 'August 2025',
      },
    ];
  }

  List<Map<String, dynamic>> getHardwareCompanies() {
    return [
      {
        'name': 'FEDERAL',
        'desc': 'Global manufacturer of electrical and mechanical products.',
        'criteria': 'CGPA 6.5+, Basic electronics knowledge',
        'placed': '35 Students',
        'link': 'https://www.federalmogul.com',
        'hiringMonth': 'February 2025',
      },
      {
        'name': 'BKT',
        'desc': 'Leading tire manufacturing company for industrial and agricultural use.',
        'criteria': 'CGPA 6.0+, Mechanical background preferred',
        'placed': '50 Students',
        'link': 'https://www.bkt-tires.com',
        'hiringMonth': 'March 2025',
      },
      {
        'name': 'INTEL',
        'desc': 'World leader in semiconductor innovation and chip manufacturing.',
        'criteria': 'CGPA 7.0+, Electronics and coding knowledge',
        'placed': '45 Students',
        'link': 'https://www.intel.com/careers',
        'hiringMonth': 'April 2025',
      },
      {
        'name': 'HP',
        'desc': 'Global computer hardware and IT services company.',
        'criteria': 'CGPA 6.5+, Hardware and software testing knowledge',
        'placed': '55 Students',
        'link': 'https://jobs.hp.com',
        'hiringMonth': 'May 2025',
      },
      {
        'name': 'NVIDIA',
        'desc': 'AI and GPU computing company transforming graphics and AI industries.',
        'criteria': 'CGPA 8.0+, Strong C++ & ML skills',
        'placed': '10 Students',
        'link': 'https://www.nvidia.com/en-in/about-nvidia/careers',
        'hiringMonth': 'June 2025',
      },
      {
        'name': 'ADANI',
        'desc': 'Leading Indian multinational in energy, logistics, and infrastructure.',
        'criteria': 'CGPA 6.0+, Electrical or Civil background preferred',
        'placed': '65 Students',
        'link': 'https://www.adani.com/careers',
        'hiringMonth': 'July 2025',
      },
      {
        'name': 'DELL',
        'desc': 'Global hardware and IT company delivering tech solutions.',
        'criteria': 'CGPA 7.0+, Networking and system knowledge',
        'placed': '70 Students',
        'link': 'https://jobs.dell.com',
        'hiringMonth': 'August 2025',
      },
      {
        'name': 'SAMSUNG',
        'desc': 'Global leader in electronics, semiconductors, and communications.',
        'criteria': 'CGPA 7.5+, Electronics & Embedded Systems',
        'placed': '100 Students',
        'link': 'https://www.samsungcareers.com',
        'hiringMonth': 'September 2025',
      },
    ];
  }

  void _showCompanyDetails(BuildContext context, Map<String, dynamic> company) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 60,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Center(
                child: Text(
                  company['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                company['desc'],
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              _infoRow("📋 Criteria:", company['criteria']),
              _infoRow("🎓 Students Placed:", company['placed']),
              _infoRow("📅 Next Hiring:", company['hiringMonth']),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(company['link']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text("Apply / Interview Link"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCompanyCard(
      BuildContext context, Map<String, dynamic> company) {
    return InkWell(
      onTap: () => _showCompanyDetails(context, company),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            company['name'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final softwareCompanies = getSoftwareCompanies();
    final hardwareCompanies = getHardwareCompanies();

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text(
          'Companies',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 3,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            const Text(
              "💻 Software Companies",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
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
              ),
              itemBuilder: (context, index) =>
                  _buildCompanyCard(context, softwareCompanies[index]),
            ),

            const SizedBox(height: 30),

          
            const Text(
              "⚙️ Hardware Companies",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
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
              ),
              itemBuilder: (context, index) =>
                  _buildCompanyCard(context, hardwareCompanies[index]),
            ),
          ],
        ),
      ),
    );
  }
}