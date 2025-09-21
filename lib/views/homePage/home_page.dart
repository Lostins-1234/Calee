import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/views/homePage/club_home.dart';
import 'package:iitropar/views/homePage/faculty_home.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import '../../database/local_db.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import '../../database/loader.dart';
//import 'package:iitropar/views/homePage/home_page.dart' show homePageKey;


final GlobalKey<_HomePageState> homePageKey = GlobalKey<_HomePageState>();


abstract class AbstractHome extends StatefulWidget {
  final Color appBarBackgroundColor;
  const AbstractHome({Key? key, required this.appBarBackgroundColor}) : super(key: key);
}

abstract class AbstractHomeState<T extends AbstractHome> extends State<T> {
  faculty f = faculty("name", "dep", "email", Set());

  AbstractHomeState() {
    _initDetails();
  }

  void _initDetails() async {
    if (FirebaseAuth.instance.currentUser != null) {
      f = await firebaseDatabase.getFacultyDetail(FirebaseAuth.instance.currentUser!.email!);
      if (mounted) setState(() {});
    }
  }

  Widget getUserImage(double radius) {
    final user = FirebaseAuth.instance.currentUser;
    final image = (user?.photoURL != null)
        ? NetworkImage(user!.photoURL!)
        : const AssetImage('assets/user1.png');

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.6), // Soft border
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: image as ImageProvider,
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surface, // Clean background
      ),
    );
  }


  String getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (Ids.role == "faculty") return "Welcome! ${f.name}";
    if (Ids.role == "club") return user?.displayName ?? "Welcome!";
    return "Hey! ${user?.displayName ?? "User"}";
  }


  List<Widget> buttons();

  Widget getText() {
    final color = Theme.of(context).colorScheme.primary;

    String text;
    if (Ids.role == "faculty") {
      text = f.department;
    } else if (Ids.role == "club") {
      text = '';
    } else {
      text = 'How are you doing today?';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16), // Adjust this to control how far from the right
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: color,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          height: 1.7,
        ),
      ),
    );

  }


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.2;
    final textSize = screenSize.width * 0.8;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: widget.appBarBackgroundColor,
        title: buildTitleBar("HOME", context),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                getUserImage(iconSize / 2 - 8),
                    const SizedBox(width: 12),
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: textSize,
                        child: Text('${getUserName()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                              Theme.of(context).colorScheme.primary, // Set text color to blue
                              fontSize: 22, // Set text size to 24
                              fontWeight:
                                  FontWeight.bold, // Set text font to bold
                            ))),
                    SizedBox(
                      width: textSize,
                      child: getText(),
                    )
                  ],
                ),
                ),
              ])), // Set text alignment to center
          Divider(
            color: Color(primaryLight),
            height: 30,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Column(
                  children: [
                    ...buttons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget themeButtonWidget() {
    return IconButton(
      onPressed: () {
      },
      icon: const Icon(
        Icons.home,
      ),
      color: Color(primaryLight),
      iconSize: 28,
    );
  }

  TextStyle appbarTitleStyle() {
    return TextStyle(
        color: Theme.of(context).colorScheme.primary,
        // fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5);
  }


  Future<void> refreshData() async {
    if (homePageKey.currentState != null) {
      await homePageKey.currentState!.refreshData();
    }
  }




  Row buildTitleBar(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 48), // Adjusted spacing to keep the layout balanced
        Text(
          text,
          style: const TextStyle(
            color: Colors.white, // Change to your preferred color
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        signoutButtonWidget(context), // Only the signout button
      ],
    );
  }

}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> refreshData() async {
    LoadingScreen.setPrompt("Refreshing Data...");
    LoadingScreen.setTask(() async {
      user = await Ids.resolveUser();
      return true;
    });
    LoadingScreen.setBuilder(userScreen);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoadingScreen.build(context)),
      );
    }
  }



  static String user = "guest";
  Future<bool> resolveUser() async {
    user = await Ids.resolveUser();
    return true;
  }

  Widget userScreen(BuildContext context) {
    if (user.compareTo('club') == 0) {
      return const ClubHome();
    } else if (user.compareTo('faculty') == 0) {
      return const FacultyHome();
    }
    return const StudentHome();
  }

  @override
  Widget build(BuildContext context) {
    LoadingScreen.setPrompt("Loading Home...");
    LoadingScreen.setTask(resolveUser);
    LoadingScreen.setBuilder(userScreen);
    return LoadingScreen.build(context);
  }
}
