// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:intl/intl.dart';

class firebaseDatabase {
  static void addEventFB(
      String eventTitle,
      String eventType,
      String eventDesc,
      String eventVenue,
      String date,
      String startTime,
      String endTime,
      String? imgURL,
      String creator) {
    String docName =
        eventTitle + date.replaceAll('/', '-') + startTime + endTime;
    DocumentReference ref_event_nr = FirebaseFirestore.instance
        .collection("Event.nonrecurring")
        .doc(docName);
    Map<String, dynamic> event = {
      "eventTitle": eventTitle,
      "eventType": eventType,
      "eventDesc": eventDesc,
      "eventVenue": eventVenue,
      "eventDate": date,
      "startTime": startTime,
      "endTime": endTime,
      "imgURL": imgURL,
      "creator": creator
    };
    ref_event_nr
        .set(event)
        .then((value) => print("event added"))
        .catchError((error) => print("failed to add event.\n ERROR =  $error"));
  }
  static void addClubEvent(
      String eventTitle,
      String eventDesc,
      String eventVenue,
      String date,
      String startTime,
      String endTime,
      String? imgURL,
      String groupName
      ) {
    String docName =
        eventTitle + date.replaceAll('/', '-');
    DocumentReference club_event_ref = FirebaseFirestore.instance
        .collection("Groups").doc(groupName).collection("Events").doc(docName);

    DateTime now = DateTime.now();
    String createdAt = DateFormat('HH:mm').format(now);

    Map<String, dynamic> event = {
      "eventTitle": eventTitle,
      "eventDesc": eventDesc,
      "eventVenue": eventVenue,
      "created":createdAt,
      "eventDate": date,
      "startTime": startTime,
      "endTime": endTime,
      "imgURL": imgURL,
      "group": groupName
    };
    club_event_ref
        .set(event);
  }

  static Future<List<dynamic>> getClubEvents(
      String group
      ) async {

    CollectionReference group_events_ref = FirebaseFirestore.instance
        .collection("Groups").doc(group).collection("Events");

    QuerySnapshot querySnapshot = await group_events_ref.get();
    int len = querySnapshot.docs.length;
    List<dynamic> group_events = [];

    for (int i = 0; i < len; i++) {
      group_events.add(querySnapshot.docs[i]);
    }
    return group_events;
  }

  static Future<List<dynamic>> getStudents(String courseID) async {
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('student_courses');
    QuerySnapshot querySnapshot = await collectionRef.get();
    int len = querySnapshot.docs.length;
    List<dynamic> students = [];
    for (int i = 0; i < len; i++) {
      List<dynamic> courses = querySnapshot.docs[i]['courses'];
      if (courses.contains(courseID)) {
        students.add(querySnapshot.docs[i].id);
      }
    }
    return students;
  }



  static Future<List<List<dynamic>>> getStudentsWithName(
      String courseID) async {
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('student_courses');
    QuerySnapshot querySnapshot = await collectionRef.get();
    int len = querySnapshot.docs.length;
    List<List<dynamic>> students = [];
    for (int i = 0; i < len; i++) {
      List<dynamic> courses = querySnapshot.docs[i]['courses'];
      if (courses.contains(courseID)) {
        students.add([querySnapshot.docs[i].id, querySnapshot.docs[i]['name']]);
      }
    }
    return students;
  }

  static void updateFaculty(faculty f) {
    DocumentReference ref_f =
    FirebaseFirestore.instance.collection("faculty").doc(f.email);
    ref_f.update({'courses': f.courses}).then((value) {
      print("faculty courses of ${f.email} updated");
    });
    for (int i = 0; i < f.courses.length; i++) {
      addCourseCode(f.courses.elementAt(i));
    }
  }
  static Future<void> removeFaculty(faculty f) async {
    DocumentReference ref_f = FirebaseFirestore.instance.collection("faculty").doc(f.email);
    await ref_f.delete();
  }

  static void addHolidayFB(String date, String desc) {
    String docName = date.replaceAll('/', '-');
    DocumentReference doc_ref =
    FirebaseFirestore.instance.collection('holidays').doc(docName);
    Map<String, String> holiday = {"date": date, "desc": desc};
    doc_ref
        .set(holiday)
        .then((value) => print("holiday added successfully"))
        .catchError(
            (error) => print("failed to add holiday.\n ERROR = $error "));
  }

  static Future<List<holidays>> getHolidayFB() async {
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('holidays');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from docs and convert map to List
    List<holidays> hols = [];
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      hols.add(holidays(
          querySnapshot.docs[i]['date'], querySnapshot.docs[i]['desc']));
    }
    return hols;
  }

  static void switchTimetableFB(String date, String day) {
    String docName = date.replaceAll('/', '-');
    DocumentReference doc_ref =
    FirebaseFirestore.instance.collection('switchTimetable').doc(docName);
    Map<String, String> switchTimetable = {
      "date": date,
      "day_to_be_followed": day
    };
    doc_ref
        .set(switchTimetable)
        .then((value) => print("added successfully"))
        .catchError((error) => print("failed to add data.\n ERROR = $error "));
  }

  static void deleteChDay(String date) {
    String docName = date.replaceAll('/', '-');
    DocumentReference doc_ref =
    FirebaseFirestore.instance.collection('switchTimetable').doc(docName);
    doc_ref.delete().then((value) {
      print('Document deleted successfully.');
    }).catchError((error) {
      print('Error deleting document: $error');
    });
  }

  static void deleteHol(String date) {
    String docName = date.replaceAll('/', '-');
    DocumentReference doc_ref =
    FirebaseFirestore.instance.collection('holidays').doc(docName);
    doc_ref.delete().then((value) {
      print('Document deleted successfully.');
    }).catchError((error) {
      print('Error deleting document: $error');
    });
  }

  static Future<List<changedDay>> getChangedDays() async {
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('switchTimetable');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from docs and convert map to List
    List<changedDay> changedDays = [];
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      changedDays.add(changedDay(querySnapshot.docs[i]['date'],
          querySnapshot.docs[i]['day_to_be_followed']));
    }
    return changedDays;
  }

  static void addCourseFB(
      String entryNumber, String name, List<dynamic> courses) {
    print(entryNumber);
    print(name);
    print(courses);
    DocumentReference ref_event_nr = FirebaseFirestore.instance
        .collection("student_courses")
        .doc(entryNumber);
    Map<String, dynamic> crs = {"name": name, "courses": courses};
    ref_event_nr
        .set(crs)
        .then((value) => print("courses added"))
        .catchError((error) => print("failed to add courses: $error"));
  }
  static Future<void> removeCoursesFB() async {
    CollectionReference collectionReference = FirebaseFirestore.instance
        .collection("student_courses");

    QuerySnapshot querySnapshot = await collectionReference.get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.delete();
    }
  }

  static void registerFacultyFB(faculty f) {
    DocumentReference ref_event_nr =
    FirebaseFirestore.instance.collection("faculty").doc(f.email);
    Map<String, dynamic> faculty = {
      "name": f.name,
      "dep": f.department,
      "email": f.email,
      "courses": f.courses
    };
    for (int i = 0; i < f.courses.length; i++) {
      addCourseCode(f.courses.elementAt(i));
    }
    ref_event_nr
        .set(faculty)
        .then((value) => print("Faculty added"))
        .catchError((error) => print("failed to add faculty: $error"));
  }

  static void registerClubFB(String clubTitle, String clubDesc, String email) {
    DocumentReference ref_event_nr =
    FirebaseFirestore.instance.collection("clubs").doc(clubTitle);
    Map<String, dynamic> clubs = {
      "clubTitle": clubTitle,
      "clubDesc": clubDesc,
      "email": email,
    };
    ref_event_nr
        .set(clubs)
        .then((value) => print("Club added"))
        .catchError((error) => print("failed to add clubs: $error"));
  }

  static Future<List<dynamic>> getClubIds() async {
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('clubs');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from dof and convert map to List
    List<dynamic> emails =
    querySnapshot.docs.map((doc) => doc['email']).toList();
    return emails;
  }

  static Future<List<dynamic>> getFacultyIDs() async {
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('faculty');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from docs and convert map to List
    List<dynamic> emails =
    querySnapshot.docs.map((doc) => doc['email']).toList();
    return emails;
  }

  static Future<String> getClubName(String clubEmail) async {
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('clubs');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from docs and convert map to List
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      if (querySnapshot.docs[i]['email'] == clubEmail) {
        return querySnapshot.docs[i]['clubTitle'];
      }
    }
    return "noclub";
  }

  static Future<faculty> getFacultyDetail(String email) async {
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('faculty');
    QuerySnapshot querySnapshot = await collectionRef.get();
    List<String> details = [];
    // Get data from docs and convert map to List
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      if (querySnapshot.docs[i]['email'] == email) {
        faculty f = faculty(
            querySnapshot.docs[i]['email'],
            querySnapshot.docs[i]['name'],
            querySnapshot.docs[i]['dep'],
            Set.from(querySnapshot.docs[i]['courses']));
        return f;
      }
    }
    faculty f = faculty("", "", "", Set());
    return f;
  }

  static Future<List<faculty>> getFaculty() async {
    List<faculty> fc = [];
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('faculty');
    QuerySnapshot querySnapshot = await collectionRef.get();
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      faculty fc_member = faculty(
          querySnapshot.docs[i]['email'],
          querySnapshot.docs[i]['name'],
          querySnapshot.docs[i]['dep'],
          Set.from(querySnapshot.docs[i]['courses']));
      fc.add(fc_member);
    }
    return fc;
  }

  static Future<List<String>> getCourses(String entryNumber) async {
    DocumentReference ref_event_nr = FirebaseFirestore.instance
        .collection("student_courses")
        .doc(entryNumber);
    bool hasCourses = await checkIfDocExists("student_courses", entryNumber);
    if (!hasCourses) {
      return [];
    }
    DocumentSnapshot snapshot = await ref_event_nr.get();
    List<String> courses = List.from(snapshot['courses']);
    return courses;
  }

  static Future<List<Event>> getEvents(DateTime date) async {
    List<Event> events = [];
    var snapshots =
    await FirebaseFirestore.instance.collection('Event.nonrecurring').get();
    for (int i = 0; i < snapshots.docs.length; i++) {
      var doc = snapshots.docs[i];
      String doc_eventDate0 = doc["eventDate"];
      List<String> date_split = doc_eventDate0.split('/');
      DateTime doc_eventDate = DateTime(
        int.parse(date_split[2]),
        int.parse(date_split[1]),
        int.parse(date_split[0]),
      );
      if (doc_eventDate.year == date.year &&
          doc_eventDate.month == date.month &&
          doc_eventDate.day == date.day) {
        Event e = Event(
            title: doc['eventTitle'],
            desc: doc['eventDesc'],
            stime: str2tod(doc['startTime']),
            etime: str2tod(doc['endTime']),
            creator: doc['creator']);
        events.add(e);
      }
    }
    return events;
  }

  static Future<String> emailCheck(String email) async {
    var fsnapshots = await FirebaseFirestore.instance.collection("faculty").get();
    var csnapshots = await FirebaseFirestore.instance.collection("clubs").get();
    for (int i = 0; i < fsnapshots.docs.length; i++) {
      var doc = fsnapshots.docs[i];
      if (doc['email'] == email) return "faculty";
    }
    for (int i = 0; i < csnapshots.docs.length; i++) {
      var doc = csnapshots.docs[i];
      if (doc['email'] == email) return "club";
    }
    if (Ids.admins.contains(email)) {
      return "admin";
    }
    return "";
  }

  static Future<changedDay?> getChangedDay(DateTime dt) async {
    String docName =
        "${dt.year.toString()}-${dt.month.toString()}-${dt.day.toString()}";
    DocumentReference documentRef =
    FirebaseFirestore.instance.collection('switchTimetable').doc(docName);
    DocumentSnapshot ds = await documentRef.get();
    if (ds.exists) {
      return changedDay(ds['date'], ds['day_to_be_followed']);
    } else {
      return null;
    }
  }

  static Future<bool> checkIfDocExists(
      String collectionName, String docId) async {
    try {
      // Get reference to Firestore collection
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection(collectionName)
          .doc(docId)
          .get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  static void addCourseCode(String courseCode) {
    DocumentReference docRef =
    FirebaseFirestore.instance.collection("coursecode").doc(courseCode);
    Map<String, dynamic> mp = {
      "coursecode": courseCode,
    };
    docRef.set(mp);
  }

  static Future<List<String>> getCourseCodes() async {
    List<String> cc = [];
    var snapshots =
    await FirebaseFirestore.instance.collection("coursecode").get();
    for (int i = 0; i < snapshots.docs.length; i++) {
      cc.add(snapshots.docs[i].id);
    }
    return cc;
  }

  static Future<bool> addExtraClass(ExtraClass c) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection("courses")
        .doc("courses")
        .collection(c.courseID)
        .doc(
        '${c.courseID}-${dateString(c.date).replaceAll('/', '-')}-${TimeString(c.startTime)}-${TimeString(c.endTime)}');
    Map<String, dynamic> exClass = {
      "courseID": c.courseID,
      "date": dateString(c.date),
      "startTime": TimeString(c.startTime),
      "endTime": TimeString(c.endTime),
      "venue": c.venue,
      "desc": c.description
    };
    docRef.set(exClass);
    return true;
  }


  static Future<semesterDur> getSemDur() async {
    DocumentReference docRef =
    FirebaseFirestore.instance.collection("semester").doc("duration");
    DocumentSnapshot ds = await docRef.get();
    List<DateTime> dts = [];
    semesterDur sd = semesterDur();
    sd.startDate = stringDate(ds['startDate']);
    sd.endDate = stringDate(ds['endDate']);
    return sd;
  }

  static Future<List<ExtraClass>> getExtraClass(String courseID) async {
    List<ExtraClass> ec = [];
    var snapshots = await FirebaseFirestore.instance
        .collection("courses")
        .doc("courses")
        .collection(courseID)
        .get();
    for (int i = 0; i < snapshots.docs.length; i++) {
      var doc = snapshots.docs[i];

      DateTime date = stringDate(doc["date"]);
      TimeOfDay startTime = StringTime(doc["startTime"]);
      TimeOfDay endTime = StringTime(doc["endTime"]);
      String description = doc["desc"];
      String venue = doc["venue"];
      ExtraClass new_c = ExtraClass(
          courseID: courseID,
          date: date,
          startTime: startTime,
          endTime: endTime,
          description: description,
          venue: venue);
      ec.add(new_c);
    }
    return ec;
  }

  static Future<List<ExtraClass>> getLabs(String courseID) async {
    List<ExtraClass> ec = [];

    // Weekday string → int (Sunday = 0, Monday = 1, ..., Saturday = 6)
    int weekdayFromString(String day) {
      const days = {
        "sunday": 0,
        "monday": 1,
        "tuesday": 2,
        "wednesday": 3,
        "thursday": 4,
        "friday": 5,
        "saturday": 6,
      };
      return days[day.toLowerCase()] ?? -1;
    }

    try {
      // Step 1: Fetch semester start and end


      // Step 2: Get groups
      var snapshot = await FirebaseFirestore.instance
          .collection("coursecode")
          .doc(courseID)
          .collection("meta")
          .doc("groups")
          .get();

      if (!snapshot.exists) return ec;

      semesterDur sd = await getSemDur();
      DateTime semStart = sd.startDate!;
      DateTime semEnd = sd.endDate!;

      List<String> groups = List<String>.from(snapshot.data()?['groups'] ?? []);

      // Step 3: Loop through groups and fetch lab info
      for (String groupName in groups) {
        var labInfoSnapshot = await FirebaseFirestore.instance
            .collection("coursecode")
            .doc(courseID)
            .collection(groupName)
            .doc("lab_info")
            .get();

        if (labInfoSnapshot.exists) {
          var data = labInfoSnapshot.data();

          String? dayStr = data?['day'];
          String? startStr = data?['start_time'];
          String? endStr = data?['end_time'];
          String? venue = data?['venue'];

          int targetWeekday = dayStr != null ? weekdayFromString(dayStr) : -1;

          if (targetWeekday >= 0 && startStr != null && endStr != null && venue != null) {
            TimeOfDay startTime = StringTime(startStr);
            TimeOfDay endTime = StringTime(endStr);

            // Step 4: Generate all matching weekdays between semStart and semEnd
            DateTime current = semStart;
            while (current.isBefore(semEnd) || current.isAtSameMomentAs(semEnd)) {
              if (current.weekday % 7 == targetWeekday) {
                ec.add(ExtraClass(
                  courseID: courseID,
                  date: current,
                  startTime: startTime,
                  endTime: endTime,
                  description: "Lab Session - $groupName",
                  venue: venue,
                ));
                current = current.add(Duration(days: 7));
              }
              else {
                current = current.add(Duration(days: 1));
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching recurring lab info: $e");
    }
    return ec;
  }


  static void deleteClass(ExtraClass c) {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection("courses")
        .doc("courses")
        .collection(c.courseID)
        .doc(
        '${c.courseID}-${dateString(c.date).replaceAll('/', '-')}-${TimeString(c.startTime)}-${TimeString(c.endTime)}');
    docRef.delete().then((value) {
      print('Document deleted successfully.');
    }).catchError((error) {
      print('Error deleting document: $error');
    });
  }

  static void clearSemester() async {
    List<String> collections = ['student_courses', 'faculty'];
    List<String> courses = await getCourseCodes();
    for (int i = 0; i < courses.length; i++) {
      collections.add("courses/courses/${courses[i]}");
    }
    for (int i = 0; i < collections.length; i++) {
      CollectionReference collectionRef =
      FirebaseFirestore.instance.collection(collections[i]);
      QuerySnapshot querySnapshot = await collectionRef.get();
      print(querySnapshot.docs);
      // Iterate over the documents and delete each one
      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.delete();
      }
    }
  }

  static void addSemDur(DateTime st, DateTime et) {
    DocumentReference docRef =
    FirebaseFirestore.instance.collection("semester").doc("duration");
    Map<String, dynamic> dur = {
      "startDate": dateString(st),
      "endDate": dateString(et),
    };
    docRef.set(dur);
  }


  static Future<Map<String, String>> getNameMapping() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('student_courses').get();
    Map<String, String> mp = {};
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      // Access the data of each document
      mp[docSnapshot.id] = docSnapshot['name'];
      // Perform operations with the data
    }
    return mp;
  }
  ////Club database code
  static void addClubGroup(
      String groupName,
      String groupDesc,
      String groupType,
      String clubName,
      ) {
    DocumentReference ref_event_nr = FirebaseFirestore.instance
        .collection("Groups")
        .doc(groupName);
    Map<String, dynamic> group = {
      "groupName": groupName,
      "associatedClub": clubName,
      "groupDesc": groupDesc,
      "groupType": groupType,
    };
    ref_event_nr
        .set(group)
        .then((value) => print("group added"))
        .catchError((error) => print("failed to add group.\n ERROR =  $error"));
  }
  static void modifyClubGroup(
      String groupName,
      String groupDesc,
      String groupType,
      ) {
    DocumentReference ref_group = FirebaseFirestore.instance
        .collection("Groups")
        .doc(groupName);
    Map<String, dynamic> group = {
      "groupDesc": groupDesc,
      "groupType": groupType,
    };
    ref_group
        .update(group)
        .then((value) => print("group modified"))
        .catchError((error) => print("failed to modify group details.\n ERROR =  $error"));
  }
  static void addClubMembers(
      String groupName,
      Set<String> memberEmails,
      ) {
    CollectionReference group_user_ref = FirebaseFirestore.instance
        .collection("Groups")
        .doc(groupName).collection('Users');
    List<String> emailIds = memberEmails.toList();
    Map<String,dynamic> details = {};
    for (String docId in memberEmails) {
      group_user_ref.doc(docId).set(details).catchError((error) => print("failed to add member.\n ERROR =  $error"));
    }
  }
  static Future<List<String>> getClubGroups(String clubName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Groups').get();
    List <String> groupNames = [];
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      if(docSnapshot['associatedClub'] == clubName){
        groupNames.add(docSnapshot.id);
      }
    }
    return groupNames;
  }
  static void addNotification(String message,String groupName){

    DateTime now = DateTime.now();
    String sentTime = DateFormat('HH:mm:ss').format(now);

    DocumentReference noti_ref = FirebaseFirestore.instance
        .collection("Groups")
        .doc(groupName)
        .collection("Notifications")
        .doc(groupName+'${now.day}-${now.month}-${now.year}'+sentTime);
    Map<String, dynamic> notification = {
      "text": message,
      "group": groupName,
      "dateSent": '${now.day}-${now.month}-${now.year}',
      "timeSent": sentTime,
    };
    noti_ref
        .set(notification)
        .then((value) => print("notification added"))
        .catchError((error) => print("failed to add notification.\n ERROR =  $error"));
  }

  static void updateMenu(String day, String breakfast, String lunch, String dinner) {
    DocumentReference menuRef = FirebaseFirestore.instance.collection("menu").doc(day);

    Map<String, dynamic> menuData = {
      "breakfast": breakfast,
      "lunch": lunch,
      "dinner": dinner
    };

    menuRef.set(menuData, SetOptions(merge: true)).then((_) {
      print("Menu updated for $day");
    }).catchError((error) {
      print("Failed to update menu: $error");
    });
  }

  static Future<Map<String, dynamic>?> getMenu(String day) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("menu").doc(day).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      print("No menu found for $day");
      return null;
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getFullMenu() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("menu").get();
    Map<String, Map<String, dynamic>> fullMenu = {};

    for (var doc in snapshot.docs) {
      fullMenu[doc.id] = doc.data() as Map<String, dynamic>;
    }
    return fullMenu;
  }

  static Future<void> addGroupToStudentCourse({
    required String roll,
    required String courseCode,
    required String groupName,
  }) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Set group for the student
    final studentGroupRef = firestore
        .collection('student_courses')
        .doc(roll)
        .collection(courseCode)
        .doc('group');

    await studentGroupRef.set({'name': groupName});

    // 2. Add roll to lab_info and create lab_info if it doesn't exist
    final labInfoRef = firestore
        .collection('coursecode')
        .doc(courseCode)
        .collection(groupName)
        .doc('lab_info');

    await firestore.runTransaction((transaction) async {
      final labSnapshot = await transaction.get(labInfoRef);
      if (!labSnapshot.exists) {
        transaction.set(labInfoRef, {
          'day': null,
          'start_time': null,
          'end_time': null,
          'venue': null,
          'students': [roll],
        });
      } else {
        transaction.update(labInfoRef, {
          'students': FieldValue.arrayUnion([roll]),
        });
      }
    });

    // 3. Update metadata group list
    final metaGroupRef = firestore
        .collection('coursecode')
        .doc(courseCode)
        .collection('meta')
        .doc('groups');

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(metaGroupRef);
      if (!snapshot.exists) {
        transaction.set(metaGroupRef, {'groups': [groupName]});
      } else {
        final data = snapshot.data();
        List<dynamic> currentGroups = data?['groups'] ?? [];

        if (!currentGroups.contains(groupName)) {
          currentGroups.add(groupName);
          transaction.update(metaGroupRef, {'groups': currentGroups});
        }
      }
    });
  }


}

