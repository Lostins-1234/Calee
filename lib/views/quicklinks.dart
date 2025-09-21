import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:adaptive_theme/adaptive_theme.dart'; // ✅ AdaptiveTheme package
import 'package:flutter/services.dart'; // ✅ For SystemNavigator.pop()

class QuickLinks extends StatefulWidget {
  final Color appBarBackgroundColor;

  const QuickLinks({
    Key? key,
    required this.appBarBackgroundColor,
  }) : super(key: key);

  @override
  State<QuickLinks> createState() => _QuickLinksState();
}

class _QuickLinksState extends State<QuickLinks> {
  final Map<String, Map<String, String>> quickLinks = {
    'Academics': {
      'Library': 'https://www.iitrpr.ac.in/library',
      'Departments': 'https://www.iitrpr.ac.in/departments-centers',
      'Course Booklet':
      'https://www.iitrpr.ac.in/sites/default/files/COURSE%20BOOKLET%20FOR%20UG%202018-19.pdf',
      'Handbook': 'https://www.iitrpr.ac.in/handbook-information',
    },
    'Facilities': {
      'Medical Centre': 'https://www.iitrpr.ac.in/medical-center/',
      'Guest House': 'https://www.iitrpr.ac.in/guest-house/',
      'Bus Timings':
      'https://docs.google.com/document/d/1oFeyY-JxaXzPH0hWT1HTMEA_nOtyz1g1w2XYEwTC9_Y/edit/',
      'Hostel': 'https://www.iitrpr.ac.in/hostels',
      'Download Forms': 'https://www.iitrpr.ac.in/downloads/forms.html',
    },
    'Student Activities': {
      'क्षितिज – The Horizon': 'https://www.iitrpr.ac.in/kshitij/',
      'TBIF': 'https://www.iitrpr.ac.in/tbif/',
      'BOST': 'https://www.iitrpr.ac.in/bost',
    },
    'Departments': {
      'Biomedical': 'http://www.iitrpr.ac.in/cbme',
      'Chemical': 'https://www.iitrpr.ac.in/chemical',
      'Chemistry': 'https://www.iitrpr.ac.in/chemistry',
      'Civil': 'https://www.iitrpr.ac.in/civil',
      'CSE': 'https://cse.iitrpr.ac.in/',
      'Electrical': 'https://ee.iitrpr.ac.in/',
      'HSS': 'https://www.iitrpr.ac.in/hss/',
      'Mathematical': 'https://www.iitrpr.ac.in/math/',
      'Physics': 'http://www.iitrpr.ac.in/physics/',
      'Mechanical': 'https://mech.iitrpr.ac.in/',
      'Metallurgical': 'https://mme.iitrpr.ac.in/',
    },
    'Our Team': {
      'Dr Puneet Goyal(Mentor)': 'https://sites.google.com/view/goyalpuneet/',
      'Aditya Garg': 'https://www.linkedin.com/in/aditya-garg-932914259/',
      'Aayan Soni': 'https://www.linkedin.com/in/aayan-soni-471379259/',
      'Akash': 'https://github.com/bInAryY-bArD',
      'Aniket Kumar Sahil':
      'https://www.linkedin.com/in/aniket-kumar-sahil-b09427258/',
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: widget.appBarBackgroundColor,
        title: buildTitleBar("QUICK LINKS", context, theme),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: ListView(
        padding: const EdgeInsets.only(top: 10),
        children: [
          // 🌙 Dark Mode Toggle Card with matching appBar color
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  Icons.brightness_6,
                  color: widget.appBarBackgroundColor, //  matches AppBar color
                ),
                title: const Text("Dark Mode"),
                trailing: Switch(
                  activeColor: widget.appBarBackgroundColor, // matches AppBar color
                  value: AdaptiveTheme.of(context).mode.isDark,
                  onChanged: (value) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Please restart the app"),
                          content: const Text(
                              "The theme has been changed. Please restart the app for changes to take effect."),
                          actions: [
                            TextButton(
                              child: const Text("Ok"),
                              onPressed: () {
                                if (value) {
                                  AdaptiveTheme.of(context).setDark();
                                } else {
                                  AdaptiveTheme.of(context).setLight();
                                }
                                Navigator.of(context).pop();
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  SystemNavigator.pop();
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // 🔗 Quick Links Cards
          ...quickLinks.entries.map((entry) {
            String category = entry.key;
            Map<String, String> links = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: theme.cardColor,
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    initiallyExpanded: quickLinks.keys.first == category,
                    leading: Icon(Icons.link, color: theme.iconTheme.color),
                    title: Text(
                      category,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge!.color,
                      ),
                    ),
                    children: [
                      for (var linkName in links.keys)
                        ListTile(
                          title: Text(
                            linkName,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge!.color,
                            ),
                          ),
                          onTap: () async {
                            String url = links[linkName]!;
                            _launchURL(url);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Row buildTitleBar(String text, BuildContext context, final theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 48), // Optional: maintains symmetry
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        signoutButtonWidget(context),
      ],
    );
  }


  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
