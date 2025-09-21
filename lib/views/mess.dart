import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart'; // ✅ Import AdaptiveTheme
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/frequently_used.dart';
import '../database/loader.dart';

class MessMenuPage extends StatefulWidget {
  final Color appBarBackgroundColor;

  const MessMenuPage({
    Key? key,
    required this.appBarBackgroundColor,
  }) : super(key: key);

  @override
  State<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage> with SingleTickerProviderStateMixin {
  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  Map<String, List<MenuItem>> _menu = Menu.menu;
  String modifyDate = "Fetching...";

  @override
  void initState() {
    super.initState();
    loadMenuAndFetchLastModified();
  }

  Future<void> loadMenuAndFetchLastModified() async {
    await Menu.fetchMenu();
    setState(() {
      _menu = Menu.menu;
    });
    getLastModified();
  }

  Future<void> getLastModified() async {
    var doc = await FirebaseFirestore.instance.collection('menu').doc("modified").get();
    setState(() {
      modifyDate = doc.data()?["date"] ?? "Unknown Date";
    });
  }

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Mon'), Tab(text: 'Tue'), Tab(text: 'Wed'),
    Tab(text: 'Thu'), Tab(text: 'Fri'), Tab(text: 'Sat'), Tab(text: 'Sun'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); //  Get current theme

    return DefaultTabController(
      initialIndex: initialDay(),
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: widget.appBarBackgroundColor, // Matches navbar color dynamically
          title: _buildTitleBar("MESS MENU", context),
          bottom: TabBar(
            labelColor: theme.colorScheme.onPrimary, // Adaptive tab text color
            unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.6),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: theme.colorScheme.onPrimary, // Same as label
                width: 1.5,
              ),
              insets: EdgeInsets.zero, // Full-width underline
            ),
            indicatorSize: TabBarIndicatorSize.tab, // Makes underline span full tab
            tabs: myTabs,
          ),


        ),
        body: TabBarView(
          children: _daysOfWeek.map((day) => _buildMenuList(day, modifyDate)).toList(),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary, // Adaptive background color
      ),
    );
  }

  Widget _buildTitleBar(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 48), // To balance spacing if needed
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                AdaptiveTheme.of(context).mode.isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.transparent,
              ),
              onPressed: () {
                // Optional: Add theme toggle functionality here
              },
            ),
            signoutButtonWidget(context),
          ],
        ),
      ],
    );
  }


  Widget _buildLastUpdatedWidget(String lastUpdatedDate) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.cardColor, // Adaptive card color
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.3), //Adaptive shadow color
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.update, color: theme.colorScheme.primary), // ✅ Adaptive icon color
          const SizedBox(width: 10),
          Text(
            'Last Updated: $lastUpdatedDate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge!.color, // ✅ Adaptive text color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(String day, String lastUpdatedDate) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLastUpdatedWidget(lastUpdatedDate),
        Expanded(
          child: ListView.builder(
            itemCount: _menu[day]?.length ?? 0,
            itemBuilder: (context, index) {
              final meal = _menu[day]![index];

              return Column(
                children: [
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: theme.cardColor, // ✅ Adaptive card color
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.3), // ✅ Adaptive shadow
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          meal.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge!.color,
                          ),
                        ),
                        leading: Icon(Icons.food_bank_rounded, color: theme.iconTheme.color),
                        subtitle: Text(checkTime(meal.name)),
                        initiallyExpanded: meal.name == mealOpen(),
                        children: _buildFoodItems(meal.description),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFoodItems(String description) {
    final theme = Theme.of(context);
    return description.split(", ").map((item) => ListTile(
      title: Text(item, style: TextStyle(color: theme.textTheme.bodyLarge!.color)), // ✅ Adaptive text
      leading: Icon(Icons.check_circle, color: Colors.green), // ✅ Adaptive icon color
    )).toList();
  }

  String mealOpen() {
    TimeOfDay now = TimeOfDay.now();
    if (now.hour <= 9 || now.hour >= 21) return "Breakfast";
    if (now.hour < 14 && now.hour > 9) return "Lunch";
    return "Dinner";
  }

  String checkTime(String name) {
    switch (name) {
      case 'Breakfast': return "7:30 AM to 9:15 AM";
      case 'Lunch': return "12:30 PM to 2:15 PM";
      default: return "7:30 PM to 9:15 PM";
    }
  }

  int initialDay() {
    DateTime now = DateTime.now();
    return now.weekday == 7 ? 0 : now.weekday - 1;
  }
  //int initialDay() => DateTime.now().weekday == 7 ? 0 : DateTime.now().weekday - 1;
}
