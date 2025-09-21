import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iitropar/database/loader.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../database/local_db.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Image logoWidget(String imageName) {
    return Image.asset(
      imageName,
      fit: BoxFit.fitWidth,
      width: 240,
      height: 240,
      color: Color(secondaryLight),
    );
  }

  void _signin() async {
    await FirebaseServices().signInWithGoogle();
    _moveToHome();
  }

  void _moveToHome() {
    print("ytuiu");
    if (FirebaseAuth.instance.currentUser == null) return;
    RootPage.signin(false);
    LoadingScreen.setPrompt("Loading Home ...");
    LoadingScreen.setTask(() async {
      try {
        print("ejw");
        if ((await Ids.resolveUser()).compareTo('student') == 0) {
          var cl = await firebaseDatabase.getCourses(
              FirebaseAuth.instance.currentUser!.email!.split('@')[0]);
          print(cl);

          await Loader.saveCourses(cl);

          // await Loader.loadMidSem(
          //   const TimeOfDay(hour: 9, minute: 30),
          //   const TimeOfDay(hour: 12, minute: 30),
          //   const TimeOfDay(hour: 14, minute: 30),
          //   const TimeOfDay(hour: 17, minute: 30),
          //   cl,
          // );
          EventDB().clearEndSem(cl);
          await Loader.loadMidSem(
            const TimeOfDay(hour: 9, minute: 30),
            const TimeOfDay(hour: 11, minute: 30),
            const TimeOfDay(hour: 12, minute: 30),
            const TimeOfDay(hour: 14, minute: 30),
            const TimeOfDay(hour: 15, minute: 30),
            const TimeOfDay(hour: 17, minute: 30),
            cl,
          );
          await Loader.loadEndSem(
            const TimeOfDay(hour: 9, minute: 30),
            const TimeOfDay(hour: 12, minute: 30),
            const TimeOfDay(hour: 14, minute: 30),
            const TimeOfDay(hour: 17, minute: 30),
            cl,
          );

        } else if ((await Ids.resolveUser()).compareTo('faculty') == 0) {
          var fd = await firebaseDatabase.getFacultyDetail(FirebaseAuth.instance.currentUser!.email!);
          List<String> cl = List.from(fd.courses);
          await Loader.saveCourses(cl);
        }
      } finally {}
      return true;
    });
    LoadingScreen.setBuilder((context) => const RootPage());

    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoadingScreen.build(context),
        settings: const RouteSettings(name: '/'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double buttonMargin = 30;
    final double buttonWidth = (screenSize.width - 2 * buttonMargin) * 0.8;

    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // stops: const [
            //   0.1,
            //   0.4,
            //   0.6,
            //   0.9,
            // ],
            colors: [Color(0xff111111), Color(0xff333333)],
          )),
          // margin: EdgeInsets.symmetric(horizontal: 80),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: screenSize.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Calee",
                        style: TextStyle(
                            color: Color(secondaryLight),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Calendar and Events",
                        style: TextStyle(
                            color: Color(secondaryLight),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Management IIT Ropar",
                        style: TextStyle(
                            color: Color(secondaryLight),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                logoWidget('assets/iitropar_logo.png'),
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: buttonMargin),
                    child: ElevatedButton(
                      onPressed: () {
                        _signin(); // navigate according to the email id
                      },
                      style: ButtonStyle(backgroundColor:
                          WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.black26;
                        }
                        return Color(secondaryLight);
                      })),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: buttonWidth * 0.8,
                              child: FittedBox(
                                child: Text(
                                  "Login with Gmail",
                                  style: TextStyle(
                                    color: Color(primaryLight),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                            Image.asset(
                              "assets/google.png",
                              width: buttonWidth * 0.2,
                              height: buttonWidth * 0.2,
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: buttonMargin),
                    child: TextButton(
                      onPressed: () {
                        RootPage.signin(false);
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const RootPage();
                              // LoadingScreen.setTask(() async {

                              //   return true;
                              // });
                              // return LoadingScreen.build(context);
                            },
                            settings: const RouteSettings(name: '/'),
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 18,
                        child: FittedBox(
                          child: Text(
                            "Don't have an account? Login as Guest.",
                            style: TextStyle(color: Color(secondaryLight)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ])
              ]),
        ),
      ),
    );
  }
}
