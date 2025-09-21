import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/views/event_calendar.dart';
import 'package:iitropar/views/events.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/views/mess.dart';
import 'package:iitropar/views/quicklinks.dart';
import 'package:iitropar/views/groups.dart';
//import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'homePage/admin_page.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class MainLandingPage extends StatefulWidget {
  const MainLandingPage({super.key});

  @override
  _MainLandingPageState createState() => _MainLandingPageState();
}

class _MainLandingPageState extends State<MainLandingPage> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }


  List<Widget> _buildScreens() {
    if (Ids.role == "admin") {
      return [
        const AdminHomePage(),
        const EventCalendarScreen(appBarBackgroundColor: Color(0xFF0D47A1)),
        const Events(appBarBackgroundColor: Color(0xFF0D47A1)),
        const MessMenuPage(appBarBackgroundColor: Color(0xFF0D47A1)),
        const QuickLinks(appBarBackgroundColor: Color(0xFF0D47A1)),
      ];
    } else if (Ids.role == "faculty") {
      return [
        const HomePage(),
        const EventCalendarScreen(appBarBackgroundColor: Color(0xFFAD1457)),
        const Events(appBarBackgroundColor: Color(0xFFAD1457)),
        const MessMenuPage(appBarBackgroundColor: Color(0xFFAD1457)),
        const QuickLinks(appBarBackgroundColor: Color(0xFFAD1457)),
      ];
    } else if (Ids.role == "club") {
      return [
        const HomePage(),
        const EventCalendarScreen(appBarBackgroundColor: Color(0xFF32A83C)),
        const Events(appBarBackgroundColor: Color(0xFF32A83C)),
        const MessMenuPage(appBarBackgroundColor: Color(0xFF32A83C)),
        const QuickLinks(appBarBackgroundColor: Color(0xFF32A83C)),
      ];
    }
    else {
      return [
        const HomePage(),
        const EventCalendarScreen(appBarBackgroundColor: Color(0xFF0D47A1)),
        const Events(appBarBackgroundColor: Color(0xFF0D47A1)),
        const Groups(),
        const MessMenuPage(appBarBackgroundColor: Color(0xFF0D47A1)),
        const QuickLinks(appBarBackgroundColor: Color(0xFF0D47A1)),
      ];
    }
  }

  List<BottomNavigationBarItem> _navbarItems() {
      return [
        const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.calendar),
        label: 'Calendar',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.event),
        label: 'Events',
      ),
      if (Ids.role != "admin" && Ids.role != "faculty" && Ids.role != "club")
        const BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Groups',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.food_bank_rounded),
        label: 'Mess Menu',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.link),
        label: 'Quick Links',
      ),

  ];
  }

  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(secondaryLight),
      body: PageView(
        key: ValueKey(AdaptiveTheme.of(context).mode), // Ensures rebuild
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _buildScreens(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: ValueKey(AdaptiveTheme.of(context).mode), // Ensures rebuild
        items: _navbarItems(),
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: _getSelectedItemColor(),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }

  Color _getSelectedItemColor() {
    if (Ids.role == "admin") {
      return const Color(0xFF0D47A1);
    } else if (Ids.role == "faculty") {
      return const Color(0xFFAD1457);
    } else if (Ids.role == "club") {
      return Colors.green;
    } else {
      return Color(0xFF42A5F5);
    }
  }

}