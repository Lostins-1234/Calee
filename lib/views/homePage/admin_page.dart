import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/views/admin/update_courses.dart';

import '../../database/loader.dart';
import '../admin/add_course_csv.dart';
import '../admin/add_event.dart';
import '../admin/add_event_csv.dart';
import '../admin/add_holidays.dart';
import '../admin/change_time_table.dart';
import '../admin/faculty_courses.dart';
import '../admin/registerClub.dart';
import '../admin/registerFaculty.dart';
import '../admin/start_sem.dart';
import '../admin/update_timetable.dart';
import '../admin/update_mid_sem_schedule.dart';
import '../admin/update_end_sem_schedule.dart';
import '../admin/updateMessMenu.dart';
import '../admin/updateVenue.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        title: buildTitleBar("ADMIN-HOME", context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Register",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AdminCard(
                        context, const NewSemester(), "Start New Semester",
                    imagePath: 'assets/admin_start_new_semester_icon.png'),
                    AdminCard(
                        context, const registerFaculty(), "Register Faculty",
                        imagePath: 'assets/admin_register_faculty_icon.png'),
                    AdminCard(context, const FacultyList(),
                        "Manage Faculty & Courses",
                    imagePath: 'assets/admin_manage_faculty_and_courses_icon.png'),
                    AdminCard(context, const addCoursecsv(),
                        "Add Student Record (CSV)",
                    imagePath: 'assets/admin_add_student_record_csv_icon.png'),
                    AdminCard(context, const registerClub(), "Register Club",
                    imagePath: 'assets/admin_register_club_icon.png'),
                  ],
                ),
              ),
              Text(
                "Alter Time-Table and Courses",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AdminCard(context, const addHoliday(), "Declare Holiday",
                    imagePath: 'assets/admin_declare_holiday_icon.png'),
                    AdminCard(
                        context, const changeTimetable(), "Change time table",
                    imagePath: 'assets/admin_change_time_table_icon.png'),
                    AdminCard(
                        context, const updateTimetablecsv(), "Update time table",
                    imagePath: 'assets/admin_update_time_table_icon.png'),
                    AdminCard(
                        context, const updateCourses(), "Update courses",
                    imagePath: 'assets/admin_update_courses_icon.png'),
                    AdminCard(context, const updateMidSemSchedule(),
                        "Update Mid-Sem Schedule",
                    imagePath: 'assets/admin_update_mid_sem_schedule_icon.png'),
                    AdminCard(context, const updateEndSemSchedule(),
                        "Update End-Sem Schedule",
                    imagePath: 'assets/admin_update_end_sem_schedule_icon.png'),
                    AdminCard(context, const updateVenue(),
                        "Update Venues",
                        imagePath: 'assets/venue.png')
                  ],
                ),
              ),
              Text(
                "Add Events",
                style: TextStyle(

                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AdminCard(context, const AddEvent(), "Add Event",
                    imagePath: 'assets/admin_add_event_icon.png'),
                    AdminCard(
                        context, const addEventcsv(), "Add Event Using CSV",
                    imagePath: 'assets/admin_add_event_using_csv_icon.png'),
                  ],
                ),
              ),
              Text(
                "Mess Management",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AdminCard(context, const UpdateMessMenu(),
                        "Update Mess Menu",
                    imagePath: 'assets/admin_update_mess_menu_icon.png'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget themeButtonWidget() {
  return IconButton(
    onPressed: () {
    },
    icon: const Icon(
      Icons.home,
      color: Colors.white,
    ),
    color: Color(secondaryLight),
    iconSize: 28,
  );
}

TextStyle appbarTitleStyle() {
  return TextStyle(
      color: Color(secondaryLight),
      // fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5);
}

Row buildTitleBar(String text, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      themeButtonWidget(),
      Flexible(
        child: SizedBox(
          height: 30,
          child: FittedBox(
            child: Text(
              text,
              style: appbarTitleStyle(),
            ),
          ),
        ),
      ),
      signoutButtonWidget(context),
    ],
  );
}
}
