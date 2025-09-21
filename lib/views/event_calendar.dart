import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/loader.dart';
import 'package:alarm/alarm.dart';


class EventCalendarScreen extends StatefulWidget {
  final Color appBarBackgroundColor;

  const EventCalendarScreen({
    Key? key,
    required this.appBarBackgroundColor,
  }) : super(key: key);

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  Map<String, List<Event>> mySelectedEvents = {};
  Map<String, List> weeklyEvents = {};
  List<holidays> listofHolidays = [];
  Map<String, String> mapofHolidays = {};
  bool holidaysLoaded = false;
  List<changedDay> listofCD = [];
  Map<String, int> mapofCD = {};
  bool CDLoaded = false;
  EventDB edb = EventDB();

  final titleController = TextEditingController();
  final descpController = TextEditingController();
  final typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getHols();
    getCD();
    mySelectedEvents = {};
    loadEvents(_selectedDate);
    //refreshData();
  }

  Future<void> refreshData() async {
    // setState(() {
    //   // Optionally show a loading indicator
    // });
    LoadingScreen.setPrompt('Fetching fresh data ...');

    // Ensure the function inside setTask returns a boolean
    await LoadingScreen.setTask(() async {
      try {
        print("Refreshing Data...");

        if ((await Ids.resolveUser()).compareTo('student') == 0) {
          var cl = await firebaseDatabase.getCourses(
              FirebaseAuth.instance.currentUser!.email!.split('@')[0]);
          print("Fetched Courses: $cl");

          await Loader.saveCourses(cl);
          await EventDB().clearEndSem(cl);
          print("Cleared EndSem");

          await Loader.loadMidSem(
            const TimeOfDay(hour: 9, minute: 30),
            const TimeOfDay(hour: 11, minute: 30),
            const TimeOfDay(hour: 12, minute: 30),
            const TimeOfDay(hour: 14, minute: 30),
            const TimeOfDay(hour: 15, minute: 30),
            const TimeOfDay(hour: 17, minute: 30),
            cl,
          );
          print("Loaded MidSem");

          await Loader.loadEndSem(
            const TimeOfDay(hour: 9, minute: 30),
            const TimeOfDay(hour: 12, minute: 30),
            const TimeOfDay(hour: 14, minute: 30),
            const TimeOfDay(hour: 17, minute: 30),
            cl,
          );
          print("Loaded EndSem");

        } else if ((await Ids.resolveUser()).compareTo('faculty') == 0) {
          var fd = await firebaseDatabase.getFacultyDetail(
              FirebaseAuth.instance.currentUser!.email!);
          List<String> cl = List.from(fd.courses);
          await Loader.saveCourses(cl);
          print("Faculty courses saved.");
        }
      } catch (e) {
        print("Error during refresh: $e");
        return false; // If there's an error, return false
      }
      return true; // Successfully completed the task
    });

    LoadingScreen.setPrompt('Almost done ...');

    // Reload event data
    await loadEvents(_selectedDate);

    setState(() {}); // Update UI after refreshing
  }


  int getAlarmId(Event event) {
    return '${event.title}_${_selectedDate}_${event.stime.format(context)}'.hashCode;
  }


  Future<bool> _isAlarmSet(Event event) async {
    int alarmId = getAlarmId(event);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if alarm is set for this event
    return prefs.getBool('alarm_$alarmId') ?? false; // Default to false if not set
  }


  Future<bool> getHols() async {
    listofHolidays = await firebaseDatabase.getHolidayFB();

    for (int i = 0; i < listofHolidays.length; i++) {
      mapofHolidays[DateFormat('yyyy-MM-dd').format(listofHolidays[i].date)] =
          listofHolidays[i].desc;
    }

    print(mapofHolidays);
    setState(() {
      holidaysLoaded = true;
    });
    return true;
  }

  Widget getDeleteButton(Event m) {
    print(m.creator);
    if (FirebaseAuth.instance.currentUser != null) {
      if (FirebaseAuth.instance.currentUser!.email == m.creator ||
          m.creator == 'guest') {
        return IconButton(
          onPressed: () => _deleteEntireEvent(m),
          icon: const Icon(Icons.delete),
          color: (Theme.of(context).colorScheme.primary).withOpacity(0.8),
        );
      }
    }
    return Container();
  }

  Future<bool> getCD() async {
    listofCD = await firebaseDatabase.getChangedDays();
   // print(listofCD[0].day_to_followed);
    for (int i = 0; i < listofCD.length; i++) {
      switch (listofCD[i].day_to_followed) {
        case "Monday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 0;
          break;
        case "Tuesday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 1;
          break;
        case "Wednesday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 2;
          break;
        case "Thursday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 3;
          break;
        case "Friday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 4;
          break;
        default:
      }
    }
    setState(() {
      CDLoaded = true;
    });
    print(mapofCD);
    return true;
  }

  loadLocalDB() async {
    await loadEvents(_selectedDate);
  }

  loadEvents(DateTime d) async {
    print("load events");
    var d1 = DateTime(d.year, d.month);
    DateTime d2;
    if (d.month == 12) {
      d2 = DateTime(d.year + 1, 1);
    } else {
      d2 = DateTime(d.year, d.month + 1);
    }
    List<Event> l = List.empty(growable: true);
    while (d1.compareTo(d2) < 0) {
      l = await edb.fetchEvents(d1);
      mySelectedEvents[DateFormat('yyyy-MM-dd').format(d1)] = l;
      for (var event in l) {
        print("Date: ${DateFormat('yyyy-MM-dd').format(d1)}, "
            "ID: ${event.id}, Title: ${event.title}, Description: ${event.desc}, "
            "Start Time: ${event.stime}, End Time: ${event.etime}, "
            "Creator: ${event.creator}, Venue: ${event.venue}, Host: ${event.host}");
      }
      d1 = d1.add(const Duration(days: 1));
    }
    setState(() {
      mySelectedEvents;
    });
  }

  updateEvents(DateTime d) async {
    var l = await edb.fetchEvents(d);
    setState(() {
      mySelectedEvents[dateString(d)] = l;
    });
  }

  updateEventsRecurring(DateTime d) async {
    DateTime s = DateTime(d.year, d.month);
    s = s.add(Duration(
        days: (d.weekday >= s.weekday)
            ? (d.weekday - s.weekday)
            : (d.weekday - s.weekday + 7)));
    while (s.month == d.month) {
      updateEvents(s);
      s = s.add(const Duration(days: 7));
    }
  }

  void _insertSingularEvent(Event e, DateTime date) async {
    await edb.addSingularEvent(e, date);
    String dateKey = DateFormat('yyyy-MM-dd').format(date);

    if (!mySelectedEvents.containsKey(dateKey)) {
      mySelectedEvents[dateKey] = [];
    }

    mySelectedEvents[dateKey]!.add(e);

    setState(() {}); // Refresh UI to show new event

    //updateEvents(date);
  }

  void _insertRecurringEvent(
      Event r, DateTime start, DateTime end, DateTime current, int mask) async {
    await edb.addRecurringEvent(r, start, end, mask);
    updateEventsRecurring(_selectedDate);
  }

  void _deleteEntireEvent(Event e) async {
    await edb.delete(e);
    loadEvents(_selectedDate);
  }
  //class _EventCalendarScreenState extends State<EventCalendarScreen> {

  // Add _setAlarm function below existing methods
  // void _setAlarm(Event event) async {
  // DateTime eventDateTime = DateTime(
  // 2025,//_selectedDate.year,
  // 3,//_selectedDate.month,
  // 14,//_selectedDate.day,
  // 18,//event.stime.hour,
  // 57,//event.stime.minute,
  // );

  void _showEventDetailsDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Date & Time
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(DateFormat('dd-MM-yyyy').format(_selectedDate),
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text("${event.startTime()} - ${event.endTime()}",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),

                // Venue & Host
                if (event.venue.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(event.venue, style: TextStyle(fontSize: 16))),
                    ],
                  ),
                if (event.host.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text("Host: ${event.host}", style: TextStyle(fontSize: 16))),
                    ],
                  ),

                const SizedBox(height: 10),

                // Description
                Text(
                  "📝 Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    event.desc.isNotEmpty ? event.desc : "No description available.",
                    style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,),
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                FutureBuilder<bool>(
                  future: _checkAlarm(event),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      // While loading, show a placeholder (centered)
                      return const Center(
                        child: Text("Checking alarm...", style: TextStyle(color: Colors.grey)),
                      );
                    }

                    final hasAlarm = snapshot.data!;

                    return Center(
                      child: TextButton.icon(
                        icon: Icon(
                          hasAlarm ? Icons.alarm_off : Icons.alarm_add,
                          color: hasAlarm ? Colors.red : Colors.green,
                        ),
                        label: Text(hasAlarm ? "Cancel Alarm" : "Set Alarm"),
                        onPressed: () {
                          if (hasAlarm) {
                            _cancelAlarm(event);
                          } else {
                            _setAlarm(event);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),




                // Delete Button (Only for creator)
                if (FirebaseAuth.instance.currentUser != null &&
                    (FirebaseAuth.instance.currentUser!.email == event.creator || event.creator == 'guest'))
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete Event"),
                      onPressed: () {
                        _deleteEntireEvent(event);
                        Navigator.pop(context);
                      },
                    ),
                  ),

                const SizedBox(height: 10),

                // Close Button
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  void _setAlarm(Event event) async {
    DateTime eventDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      event.stime.hour,
      event.stime.minute,
    );

    DateTime alarmTime = eventDateTime.subtract(Duration(minutes: 10));

    // Prevent setting alarms for past events
    if (alarmTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot set alarm for a past event.")),
      );
      return;
    }

    // Create unique alarm ID based on event details
    final alarmKey = '${event.title}_${_selectedDate}_${event.stime.format(context)}'.hashCode;

    final alarmSettings = AlarmSettings(
      id: alarmKey, // Use custom unique ID
      dateTime: alarmTime,
      assetAudioPath: 'assets/betteralarm.mp3', // Optional custom sound
      loopAudio: false,
      vibrate: true,
      fadeDuration: 3.0,
      notificationTitle: "Reminder: ${event.title}",
      notificationBody: "Your event starts at ${event.stime.format(context)}.",
    );

    // Set the alarm
    await Alarm.set(alarmSettings: alarmSettings);

    // Save alarm state in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_$alarmKey', true); // Use the same key for saving

    setState(() {});

    String formattedDate = "${alarmTime.day}-${alarmTime.month}-${alarmTime.year}";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Alarm set for ${event.title} on $formattedDate at ${alarmTime.hour}:${alarmTime.minute}")),
    );
  }


Future<bool> _checkAlarm(Event event) async {
  final alarmKey = '${event.title}_${_selectedDate}_${event.stime.format(context)}'.hashCode;

  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool hasAlarm = prefs.getBool('alarm_$alarmKey') ?? false;

  return hasAlarm;
}


  void _cancelAlarm(Event event) async {
    // Create unique alarm ID based on event details
    final alarmKey = '${event.title}_${_selectedDate}_${event.stime.format(context)}'.hashCode;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool hasAlarm = prefs.getBool('alarm_$alarmKey') ?? false; // Use the same key for checking
    if (hasAlarm) {
      bool isDeleted = await Alarm.stop(alarmKey); // Stop the alarm using the unique key
      if (isDeleted) {
        await prefs.remove('alarm_$alarmKey'); // Remove the alarm from SharedPreferences
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alarm for '${event.title}' has been canceled.")),
        );
        setState(() {}); // Update bell icon
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No active alarm found for '${event.title}'.")),
      );
    }
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  // List<Event> _listOfDayEvents(DateTime datetime) {
  //   var l = mySelectedEvents[DateFormat('yyyy-MM-dd').format(datetime)];
  //
  //   if (l != null) {
  //     l.sort((a, b) => a.compareTo(b));
  //     return l;
  //   }
  //   return List.empty();
  // }


  bool isHoliday(DateTime day) {
    if (day.weekday >= 6) {
      return true;
    }

    if (holidaysLoaded == true) {
      String cmp = DateFormat('yyyy-MM-dd').format(day);
      if (mapofHolidays[cmp] != null) {
        return true;
      }
    }

    return false;
  }


  List<Event> _listOfDayEvents(DateTime datetime) {
    String dateKey = DateFormat('yyyy-MM-dd').format(datetime);

    if (!mySelectedEvents.containsKey(dateKey) || mySelectedEvents[dateKey] == null) {
      return []; // Ensure an empty list is returned instead of null
    }

    List<Event> l = List.from(mySelectedEvents[dateKey]!);

    DateTime cdate = whatDatetocall(datetime);
    if(cdate != datetime){
      l.removeWhere((event) => event.desc == "Class" || event.desc == "Tutorial");
      String newdate = DateFormat('yyyy-MM-dd').format(cdate);
      // if(isHoliday(cdate)){
      //
      // }
      if (!mySelectedEvents.containsKey(newdate) || mySelectedEvents[newdate] == null) {
        l.sort((a, b) => a.stime.hour.compareTo(b.stime.hour));
        return l;
      }
      List<Event> l2 = List.from(mySelectedEvents[newdate] ?? []);
      l2.removeWhere((event) => event.desc != "Class" && event.desc != "Tutorial");
      l.addAll(l2);
    }

    // Ensure sorting doesn't crash
    l.sort((a, b) => a.stime.hour.compareTo(b.stime.hour));

    return l;
  }



  DateTime whatDatetocall(DateTime datetime) {
    if (CDLoaded) {
      if (mapofCD[DateFormat("yyyy-MM-dd").format(datetime)] != null) {
        int wkday = datetime.weekday - 1;
        int dtf = mapofCD[DateFormat("yyyy-MM-dd").format(datetime)]!;
        if (dtf > wkday) {
          return datetime.add(Duration(days: dtf - wkday));
        } else {
          return datetime.subtract(Duration(days: wkday - dtf));
        }
      }
    }
    if (holidaysLoaded) {
      if (mapofHolidays[dateString(datetime)] != null) {
        return datetime.add(const Duration(days: 1000));
      }
    }
    return datetime;
  }

  String? holidayScript(DateTime date) {
    if (holidaysLoaded) {
      return mapofHolidays[dateString(date)];
    }
    return null;
  }

  _showSingleAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: const Text(
            "Add New Event",
            textAlign: TextAlign.center,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Text(DateFormat('dd-MM-yyyy').format(_selectedDate)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.add(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                );
              }),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descpController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                          context: context, initialTime: startTime);
                      if (newTime != null) {
                        setState(() {
                          startTime = newTime;
                        });
                      }
                    },
                    child: Text(
                      "Start Time : ${formatTimeOfDay(startTime)}",
                      style: const TextStyle(fontSize: 18),
                    ));
              }),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                          context: context, initialTime: endTime);
                      if (newTime != null) {
                        setState(() {
                          endTime = newTime;
                        });
                      }
                    },
                    child: Text(
                      "End Time : ${formatTimeOfDay(endTime)}",
                      style: const TextStyle(fontSize: 18),
                    ));
              }),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  titleController.clear();
                  descpController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      descpController.text.isEmpty ||
                      toDouble(endTime) < toDouble(startTime)) {
                      Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:const  Text(
                            "Please ensure that the title, description, and times are properly entered."),
                        duration: const Duration(seconds: 5),
                        backgroundColor: Colors.purple,
                        behavior: SnackBarBehavior
                            .floating, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );
                  } else {
                    print("Adding Singular Event");
                    Event s = Event(
                      title: titleController.text,
                      desc: descpController.text,
                      stime: startTime,
                      etime: endTime,
                      creator:
                          (FirebaseAuth.instance.currentUser!.email == null)
                              ? ('guest')
                              : (FirebaseAuth.instance.currentUser!.email!),
                    );
                    _insertSingularEvent(s, _selectedDate);

                    titleController.clear();
                    descpController.clear();
                    typeController.clear();
                    Navigator.pop(context);
                    return;
                  }
                },
                child: const Text("Add Event")),
          ],
        ),
      ),
    );
  }

  _showRecurringAddEventDialog() async {
    endDate = _selectedDate;
    await showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: const Text(
            "Add New Recurring Event",
            textAlign: TextAlign.center,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Text(DateFormat('dd-MM-yyyy').format(_selectedDate)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.add(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                );
              }),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descpController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                          context: context, initialTime: startTime);
                      if (newTime != null) {
                        setState(() {
                          startTime = newTime;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 30,
                      child: FittedBox(
                        child: Text(
                          "Start Time : ${formatTimeOfDay(startTime)}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ));
              }),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                          context: context, initialTime: endTime);
                      if (newTime != null) {
                        setState(() {
                          endTime = newTime;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 30,
                      child: FittedBox(
                        child: Text(
                          "End Time : ${formatTimeOfDay(endTime)}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ));
              }),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100));

                      if (newDate != null) {
                        setState(() {
                          endDate = newDate;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 30,
                      child: FittedBox(
                        child: Text(
                          "End Date : ${DateFormat('dd-MM-yyyy').format(endDate)}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ));
              }),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  titleController.clear();
                  descpController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  startDate = _selectedDate;
                  if (titleController.text.isEmpty ||
                      descpController.text.isEmpty ||
                      startDate.compareTo(endDate) > 0 ||
                      toDouble(endTime) < toDouble(startTime)) {
                       Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            "Please ensure that the title, description, and times are properly entered."),
                        duration:const Duration(seconds: 5),
                        backgroundColor: Colors.purple,
                        behavior: SnackBarBehavior
                            .floating, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );
                    return;
                  } else {
                    print("Adding Recurring Event");
                    Event r = Event(
                      title: titleController.text,
                      desc: descpController.text,
                      stime: startTime,
                      etime: endTime,
                      creator:
                          (FirebaseAuth.instance.currentUser!.email == null)
                              ? ('guest')
                              : (FirebaseAuth.instance.currentUser!.email!),
                    );
                    _insertRecurringEvent(r, startDate, endDate, _selectedDate,
                        ((1 << (startDate.weekday - 1))));

                    titleController.clear();
                    descpController.clear();
                    typeController.clear();
                    Navigator.pop(context);
                    return;
                  }
                },
                child: const Text("Add Event")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? holidayResaon = holidayScript(_selectedDate);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 50,
          title: buildTitleBar("EVENT CALENDAR", context),
          backgroundColor: widget.appBarBackgroundColor,
          elevation: 0,
        ),
        // drawer: const NavDrawer(),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: Column(
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.height - 80) / 2,
              child: TableCalendar(
                shouldFillViewport: true,
                focusedDay: _focused,
                firstDay: DateTime(2024),
                lastDay: DateTime(2028).subtract(const Duration(days: 1)),
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDate, selectedDay)) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _focused = focusedDay;
                    });
                  }
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                enabledDayPredicate: (day) {
                  return _focused.month == day.month;
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focused = focusedDay;
                  });
                  loadEvents(focusedDay);
                },
                eventLoader: (datetime) {
                  //return _listOfDayEvents(whatDatetocall(datetime));
                  return _listOfDayEvents(datetime);
                },
                holidayPredicate: (day) {
                  return isHoliday(day);
                },
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                currentDay: DateTime.now(),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible : true,
                  outsideTextStyle: TextStyle(color: Colors.green),
                    selectedDecoration: BoxDecoration(
                        color: Color.fromARGB(255, 56, 56, 56), shape: BoxShape.circle),
                    todayDecoration: const BoxDecoration(
                        color: Color.fromARGB(255, 149, 149, 149), shape: BoxShape.circle)),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) {
                      return Container();
                    }

                    return Container(
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.orangeAccent),
                    );
                  },
                  holidayBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Text("${day.day}",
                          style: TextStyle(color: Colors.red)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 0,
            ),
            Divider(
              height: 5,
              thickness: 1,
              color: Color(primaryLight).withOpacity(0.05),
            ),
            Expanded(
              child: ListView(
                children: [
                  ..._listOfDayEvents(_selectedDate).map((myEvents) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            _showEventDetailsDialog(myEvents);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                // Bell icon
                                FutureBuilder<bool>(
                                  future: _isAlarmSet(myEvents), // Check if the alarm is set
                                  builder: (context, snapshot) {
                                    Color bellColor = Colors.grey[400]!.withOpacity(0.6); // Default grey color
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      // If alarm is set, color the bell green
                                      if (snapshot.data == true) {
                                        bellColor = Colors.green;
                                      }
                                    }
                                    return Icon(
                                      Icons.notifications_active,
                                      size: 20,
                                      color: bellColor, // Set bell color dynamically
                                    );
                                  },
                                ),
                                const SizedBox(width: 10), // Add some space between the bell and text

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        myEvents.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                        ),
                                      ),
                                      Text(
                                        myEvents.startTime() + " - " + myEvents.endTime(),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Indicator
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 3,
                          thickness: 1,
                          color: Color(primaryLight).withOpacity(0.05),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(
                    height: 19,
                  ),
                  Text(
                    holidayResaon ?? '',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

            ),

          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  height: 120.0,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: const Icon(Icons.event),
                          title: const Text('Add Event'),
                          onTap: () {
                            Navigator.pop(context);
                            _showSingleAddEventDialog();
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          leading: const Icon(Icons.repeat),
                          title: const Text('Add Recurring Event'),
                          onTap: () {
                            Navigator.pop(context);
                            _showRecurringAddEventDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          // backgroundColor: Color(primaryLight), #changedbitxh
            backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ));
  }

//  DateTime currentDate = DateTime.now();
//   List<Event> events = _listOfDayEvents(whatDatetocall(currentDate));

  // Widget themeButtonWidget() {
  //   return IconButton(
  //     onPressed: () {
  //       refreshData();
  //     },
  //     icon: const Icon(
  //       Icons.sync_rounded,
  //     ),
  //     color: Color(primaryLight),
  //     iconSize: 28,
  //   );
  // }

  TextStyle appbarTitleStyle() {
    return TextStyle(
        color: Color(primaryLight),
        // fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5);
  }

  Row buildTitleBar(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
        onPressed: () async {
      // Show the loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Refreshing data..."),
            ],
          ),
        ),
      );

      await refreshData(); // Your function to fetch/update data

      // Close the dialog
      if (context.mounted) Navigator.of(context).pop();
    },
          icon: const Icon(Icons.sync_rounded),
          color: Colors.white, // Change to your preferred color
          iconSize: 28,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white, // Change to your preferred color
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        signoutButtonWidget(context),
      ],
    );
  }
}
