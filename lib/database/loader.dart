// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:intl/intl.dart';
import 'event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Loader {
  static String convertTo24(String time, String segment) {
    int hour = int.parse(time.split('.')[0]);
    int min = int.parse(time.split('.')[1]);
    if (segment.toLowerCase().compareTo('am') != 0) {
      if (hour != 12) hour += 12;
    } else if (hour == 12) {
      hour = 0;
    }
    return '${hour.toString().padLeft(2, "0")}:${min.toString().padLeft(
        2, "0")}';
  }

  static Map<String, String>? courseToSlot;
  static Map<String, String>? courseToProff;
  static Map<String, List<String>>? slotToTime;

  static Map<String, String>? courseToClassVenue; // Maps course to class venue
  static Map<String,
      String>? courseToTutorialVenue; // Maps course to tutorial venue


  static Future<void> loadSlots() async {
    void listFiles() async {
      final ListResult result = await FirebaseStorage.instance.ref().listAll();
      for (var item in result.items) {
        print("Found file: ${item.name}");
      }
    }


    //print("hello");
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('CourseSlots.csv');

    try {
      final Uint8List? csvData = await ref.getData(10 * 1024 * 1024);
      (print(csvData?.length));
      print(csvData);
      if (csvData != null && csvData.isNotEmpty) {
        print("Raw CSV Data (first 100 bytes): ${csvData.sublist(
            0, csvData.length)}");
      } else {
        print("CSV Data is empty or null");
      }


      if (csvData != null) {
        // Decode CSV data into a String
        final String decodedData = utf8.decode(csvData, allowMalformed: true);
        //final String decodedData = utf8.decode(csvData);
        print("Successfully fetched CourseSlots.csv");
        print("Decoded CSV String Length: ${decodedData.length}");
        List<String> lines = decodedData.split("\n");

        for (int i = 0; i < lines.length; i++) {
          print("Line $i: ${lines[i]}");
        }
        // for (int i = 0; i < decodedData.length; i += 500) {
        //   print(decodedData.substring(i, i + 500 > decodedData.length ? decodedData.length : i + 500));
        // }
        //print(decodedData);
        // Parse CSV string into a list of lists
        List<List<dynamic>> courseSlots = const CsvToListConverter(eol: "\n",
          fieldDelimiter: ",",).convert(
            decodedData);
        // print(courseSlots);

        courseToSlot = {};
        courseToProff = {};

        for (final slot in courseSlots) {
          if (slot[0].runtimeType == int) {
            final courseName = slot[1].toString().replaceAll(' ', '');
            courseToSlot![courseName] = slot[3];
            courseToProff![courseName] = slot[6];
          }
        }
        // print(courseToSlot);
        // print(courseToProff);
      }
    }
    catch (e) {
      print('Error loading CSV file: $e');
    }
  }


  static Future<void> loadVenues() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('Venue.csv');

    try {
      // Try to download the CSV file as a byte stream
      final Uint8List? csvData = await ref.getData();
      if (csvData != null) {
        // Decode CSV data into a String
        final String decodedData = utf8.decode(csvData);
        print(decodedData);

        // Parse CSV string into a list of lists
        List<List<dynamic>> venueData = const CsvToListConverter().convert(
            decodedData);
        int len = venueData.length;

        print("Venue Table:");
        debugPrint(venueData[0].toString(), wrapWidth: 1024);

        courseToClassVenue = {}; // Initialize map for class venues
        courseToTutorialVenue = {}; // Initialize map for tutorial venues

        for (int i = 1; i < len; i++) {
          if (venueData[i].length >= 3) {
            String course = venueData[i][0].toString().trim();
            String classVenue = venueData[i][1].toString().trim();
            String tutorialVenue = venueData[i][2].toString().trim();

            courseToClassVenue![course] = classVenue;
            courseToTutorialVenue![course] = tutorialVenue;
          }
        }

        print("Course to Class Venue Mapping:");
        print(courseToClassVenue);
        print("Course to Tutorial Venue Mapping:");
        print(courseToTutorialVenue);
      }
    } catch (e) {
      print('Error loading Venue CSV file: $e');
    }
  }

  static Future<void> loadTimes() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('TimeTable.csv');

    try {
      // Try to download the CSV file as a byte stream
      final Uint8List? csvData = await ref.getData();
      if (csvData != null) {
        // Decode CSV data into a String
        final String decodedData = utf8.decode(csvData);
        print(decodedData);
        // Parse CSV string into a list of lists
        List<List<dynamic>> slotTimes = const CsvToListConverter().convert(
            decodedData);
        var len = slotTimes.length;
        print("Time Table");
        debugPrint(slotTimes[0].toString(), wrapWidth: 1024);
        print(slotTimes[0].length);


        slotToTime = {};

        List<String> timings = slotTimes[0].cast<String>();
        for (int i = 1; i < timings.length; i++) {
          List<String> tokens = timings[i].split(' ');
          if (tokens.length != 4) continue;
          timings[i] =
              '${convertTo24(tokens[0], tokens[3])}|${convertTo24(
                  tokens[2], tokens[3])}'
                  .toLowerCase();
        }

        for (int i = 1; i < len; i++) {
          int sz = slotTimes[i].length;
          print(sz);
          print("size");
          String weekday = slotTimes[i][0];
          weekday = weekday.toLowerCase();

          for (int j = 1; j < sz; j++) {
            String slot = slotTimes[i][j].replaceAll(' ', '');
            print(slot);
            if (slotToTime![slot] == null) {
              slotToTime![slot] = List.empty(growable: true);
            }
            slotToTime![slot]!.add('$weekday|${timings[j]}');
          }
        }
        print("slottotime");
        if (slotToTime != null && slotToTime!.containsKey("T-PCE-1")) {
          print("contains");
        }
      }
    } catch (e) {
      print('Error loading CSV file: $e');
    }
  }

  static Future<bool> saveCourses(List<String> course_id) async {
    print("yeah");
    print(course_id);

    EventDB().deleteOf("course");

    //  Preprocess
    for (int i = 0; i < course_id.length; i++) {
      course_id[i] = course_id[i].replaceAll(' ', '');
    }

    // if (courseToSlot == null) {
    //   await loadSlots();
    // }
    await loadSlots();
    print("loaded Times");
    await loadTimes();
    await loadVenues();
    // if (slotToTime == null) {
    //   await loadTimes();
    // }

    semesterDur sd = await firebaseDatabase.getSemDur();


    for (int i = 0; i < course_id.length; i++) {
      await saveExtraClasses(course_id[i]);
      for (int j = 0; j < 2; j++) {
        String? slot = courseToSlot![course_id[i]];
        //  Processes as Tutorial or Class
        slot = (j == 0) ? (slot) : ('T-$slot');
        String title = course_id[i];
        String host = courseToProff![course_id[i]].toString();
        String desc = (j == 0) ? 'Class' : 'Tutorial';

        List<String>? times = slotToTime![slot];
        if (times == null) continue;

        for (int j = 0; j < times.length; j++) {
          var l = times[j].split('|');
          String day = l[0];
          int mask = 0;
          const weekdays = [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday'
          ];
          for (int k = 0; k < 7; k++) {
            if (day.compareTo(weekdays[k]) == 0) {
              mask = 1 << k;
              break;
            }
          }

          String stime = l[1];
          String etime = l[2];

          String venue = "";
          if (desc == "Class") {
            venue = (courseToClassVenue ?? {})[title] ?? "No Venue";
          } else if (desc == "Tutorial") {
            venue = (courseToTutorialVenue ?? {})[title] ?? "No Venue";
          }

          Event e = Event(
              title: title,
              desc: desc,
              stime: str2tod(stime),
              etime: str2tod(etime),
              creator: 'course',
              venue: venue,
              host: host
          );
          try {
            await EventDB().addRecurringEvent(
              e,
              sd.startDate!,
              sd.endDate!,
              mask,
            );
          } catch (e) {
            continue;
          }
        }
      }
    }

    return true;
  }

  static Future<void> loadMidSem(
      TimeOfDay slot1_start,
      TimeOfDay slot1_end,
      TimeOfDay slot2_start,
      TimeOfDay slot2_end,
      TimeOfDay slot3_start,
      TimeOfDay slot3_end,
      List<String> courses,
      ) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('MidSemTable.csv');

    await loadSlots();

    try {
      print("Loading Midsem CSV...");
      final Uint8List? csvData = await ref.getData();
      if (csvData != null) {
        final String decodedData = utf8.decode(csvData);
        List<List<dynamic>> exams = const CsvToListConverter(eol: '\n').convert(decodedData);

        Map<String, String> slotToDay = {};
        for (int i = 0; i < exams.length; i++) {
          if (exams[i].length != 4) {
            print("Error in midsem csv at row $i: Expected 4 columns (date, slot1, slot2, slot3)");
            throw ArgumentError("Invalid CSV format at row $i");
          }

          DateTime startDate = DateFormat('dd-MM-yyyy').parse(exams[i][0]);

          List<String> slot1_courses = exams[i][1].toString().split('|').where((e) => e.trim().isNotEmpty).toList();
          List<String> slot2_courses = exams[i][2].toString().split('|').where((e) => e.trim().isNotEmpty).toList();
          List<String> slot3_courses = exams[i][3].toString().split('|').where((e) => e.trim().isNotEmpty).toList();

          for (var course in slot1_courses) {
            slotToDay[course.trim()] = "${dateString(startDate)}|${tod2str(slot1_start)}|${tod2str(slot1_end)}";
          }
          for (var course in slot2_courses) {
            slotToDay[course.trim()] = "${dateString(startDate)}|${tod2str(slot2_start)}|${tod2str(slot2_end)}";
          }
          for (var course in slot3_courses) {
            slotToDay[course.trim()] = "${dateString(startDate)}|${tod2str(slot3_start)}|${tod2str(slot3_end)}";
          }
        }

        print("Parsed Slot to Day Map:");
        print(slotToDay);

        for (var course in courses) {
          if (!slotToDay.containsKey(course)) continue;
          var l = slotToDay[course]!.split('|');
          var e = Event(
            title: 'Mid-Sem Exam',
            desc: course,
            stime: str2tod(l[1]),
            etime: str2tod(l[2]),
            creator: 'Exam',
          );
          print("Adding Midsem Event for course ${course}");
          EventDB().addSingularEvent(e, stringDate(l[0]));
        }
      }
    } catch (e) {
      print("Error loading Midsem CSV: $e");
    }
  }

  static Future<void> loadEndSem(TimeOfDay morningSlot_start,
      TimeOfDay morningSlot_end,
      TimeOfDay eveningSlot_start,
      TimeOfDay eveningSlot_end,
      List<String> courses,) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('EndSemTable.csv');

    if (courseToSlot == null) {
      await loadSlots();
    }
    try {
      // Try to download the CSV file as a byte stream
      final Uint8List? csvData = await ref.getData();
      if (csvData != null) {
        // Decode CSV data into a String
        String decodedData = utf8.decode(csvData);
        // print("========== Raw Decoded Data ==========");
        // print(decodedData);
        // print("=======================================");

        // Parse CSV string into a list of lists
        List<List<dynamic>> exams = const CsvToListConverter(
          eol: '\n',).convert(decodedData);


        print("EndSem data");
        print(exams.length);
        print(exams);

        Map<String, String> slotToDay = {};
        for (int i = 0; i < exams.length; i++) {
          if (exams[i].length != 3) {
            throw ArgumentError("Invalid CSV");
          }
          DateTime startDate = DateFormat('dd-MM-yyyy').parse(exams[i][0]);
          List<String> courses1 = exams[i][1].split('|');
          for (int j = 0; j < courses1.length; j++) {
            slotToDay[courses1[j]] =
            "${dateString(startDate)}|${tod2str(morningSlot_start)}|${tod2str(
                morningSlot_end)}";
          }

          List<String> courses2 = exams[i][2].split('|');
          for (int j = 0; j < courses2.length; j++) {
            slotToDay[courses2[j]] =
            "${dateString(startDate)}|${tod2str(eveningSlot_start)}|${tod2str(
                eveningSlot_end)}";
          }
        }
        print("endsem");
        print(slotToDay);
        for (int i = 0; i < courses.length; i++) {
          if (!slotToDay.containsKey(courses[i])) continue;
          var l = slotToDay[courses[i]]!.split('|');
          var e = Event(
              title: 'End-Sem Exam',
              desc: courses[i],
              stime: str2tod(l[1]),
              etime: str2tod(l[2]),
              creator: 'Exam');
          EventDB().addSingularEvent(e, stringDate(l[0]));
        }
      }
    } catch (e) {}
  }

  static Future<List<ExtraClass>> loadExtraClasses(String course) async {
    List<ExtraClass> extras = await firebaseDatabase.getExtraClass(course);
    List<ExtraClass> labs = await firebaseDatabase.getLabs(course);
    print("Here are the labs");
    print(labs);
    extras.addAll(labs); // Append labs to extras
    return extras;
  }


  static Future<void> saveExtraClasses(String course_id) async {
    List<ExtraClass> extraclasses =
    await firebaseDatabase.getExtraClass(course_id);

    String role = Ids.role;
    String entryNumber = FirebaseAuth.instance.currentUser!.email!.split(
        '@')[0];
    String? groupName;

    if (role == 'student') {
      final groupDoc = await FirebaseFirestore.instance
          .collection('student_courses')
          .doc(entryNumber) // roll number
          .collection(course_id) // courseCode
          .doc('group') // document named 'group'
          .get();

      if (groupDoc.exists && groupDoc.data() != null) {
        groupName = groupDoc.data()!['name'] as String?;
      }

      print("groupname");
      print(groupName);
    }


    List<ExtraClass> labs = await firebaseDatabase.getLabs(course_id);
    if (role == 'student' && groupName != null) {
      labs = labs.where((lab) => lab.description.trim().endsWith(groupName!))
          .toList();
    }
    extraclasses.addAll(labs); // Append labs to extras


    for (ExtraClass c in extraclasses) {
      Event e = Event(
        title: c.courseID,
        desc: c.description,
        stime: c.startTime,
        etime: c.endTime,
        venue: c.venue,
        host: courseToProff![c.courseID].toString(),
        creator: 'course',
      );
      await EventDB().addSingularEvent(e, c.date);
    }
  }

}