import 'package:flutter/material.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:intl/intl.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:intl/intl.dart';



double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

class StudentHome extends AbstractHome {
  const StudentHome({Key? key})
      : super(
    key: key,
    appBarBackgroundColor: const Color(0xFF0D47A1),
  );

  @override
  State<AbstractHome> createState() => _StudentHomeState();
}

String getDay() {
  return DateFormat('EEEE').format(DateTime.now());
}

Future<String> getImageUrl(String item) async {
  try {
    Reference storageReference = FirebaseStorage.instance.ref().child('$item.png');
    String downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    return ''; // Return empty string to indicate file not found
  }
}

Widget buildItems(String item) {
  item = item.replaceAll("/", "_");
  return FutureBuilder(
    future: getImageUrl(item),
    builder: (context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(primaryLight),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/food_logo.png')
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item,
                  style: TextStyle(fontSize: 14, color: Color(primaryLight)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        String imageUrl = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(primaryLight),
                  child:CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                    // child:Image.network(
                    //   imageUrl,
                    //   fit: BoxFit.contain,
                    //   errorBuilder: (context, error, stackTrace) {
                    //     return  Image.asset(
                    //     'assets/food_logo.png',
                    //     fit: BoxFit.cover,);
                    //      },),
                ),
                ),
                const SizedBox(height: 5),
                Text(
                  item,
                  style: TextStyle(fontSize: 14, color: Color(primaryLight)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
    },
  );
}


Widget divider() {
  return const Divider(
    color: Colors.black,
    height: 30,
    thickness: 1,
    indent: 30,
    endIndent: 30,
  );
}

class _StudentHomeState extends AbstractHomeState {

  List<holidays> listofHolidays = [];
  Map<String, String> mapofHolidays = {};
  bool holidaysLoaded = false;
  List<changedDay> listofCD = [];
  Map<String, int> mapofCD = {};
  bool CDLoaded = false;


  List<Event> tomorrowevents = [];
  List<Event> todayevents = [];
  bool showRightArrow = true;
  bool showLeftArrow = false;
  @override
  void initState() {
    super.initState();
    //getHols();
    initializeData();

    // getHols();
    // getCD();
    // loadEventstoday();
    // loadEventstomorrow();
  }

  void initializeData() async {
    await getHols(); // Ensure holidays are fetched first
    await getCD(); // Fetch changed days after holidays
    loadEventstoday(); // Now load events with a non-empty mapOfHolidays
    loadEventstomorrow();
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
      print("it is a holiday");
      if (mapofHolidays[dateString(datetime)] != null) {
        print("In the distant future");
        return datetime.add(const Duration(days: 1000));
      }
    }
    print("not a holiday");
    return datetime;
  }


  Future<void> loadEventstoday() async {
    try {
      List<Event> loadedTodayEvents =
          await EventDB().fetchEvents(DateTime.now());
      print("list of holidays");
      print(mapofHolidays);
      DateTime x = whatDatetocall(DateTime.now());
      print("whatdate");
      print(x);
      print("x printed");
      //if(x != DateTime.now()){
        List<Event> l = await EventDB().fetchEvents(x);
        loadedTodayEvents.removeWhere((event) => event.desc == "Class" || event.desc == "Tutorial");
        //String newdate = DateFormat('yyyy-MM-dd').format(cdate);

        l.removeWhere((event) => event.desc != "Class" && event.desc != "Tutorial");
        loadedTodayEvents.addAll(l);
      //}

      setState(() {
        todayevents = loadedTodayEvents;
      });
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Future<void> loadEventstomorrow() async {
    try {
      List<Event> loadedTomorrowEvents =
          await EventDB().fetchEvents(DateTime.now().add(const Duration(days: 1)));
      DateTime x = whatDatetocall(DateTime.now().add(const Duration(days: 1)));
      //if(x != DateTime.now()){
        List<Event> l = await EventDB().fetchEvents(x);
        loadedTomorrowEvents.removeWhere((event) => event.desc == "Class" || event.desc == "Tutorial");
        //String newdate = DateFormat('yyyy-MM-dd').format(cdate);

        l.removeWhere((event) => event.desc != "Class" && event.desc != "Tutorial");
        loadedTomorrowEvents.addAll(l);
      //}
      setState(() {
        tomorrowevents = loadedTomorrowEvents;
      });
    } catch (e) {
      print('Error loading events: $e');
    }
  }
  //import 'package:intl/intl.dart';

  Widget todayEvents() {
    String todayDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Today's Events", todayDate),
        gettodayEvents(),
      ],
    );
  }

  Widget tomorrowEvents() {
    String tomorrowDate =
    DateFormat('EEEE, MMM d').format(DateTime.now().add(Duration(days: 1)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Tomorrow's Events", tomorrowDate),
        gettomorrowEvents(),
      ],
    );
  }

  Widget _sectionHeader(String title, String date) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface, // Adapts for both themes
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }






  Widget eventWidget(Event myEvents) {
    // Determine prefix from description
    String descPrefix = '';
    if (myEvents.desc.toLowerCase().startsWith('lab')) {
      descPrefix = 'P';
    } else if (myEvents.desc.toLowerCase().startsWith('tutorial')) {
      descPrefix = 'T';
    } else if (myEvents.desc.toLowerCase().startsWith('class')) {
      descPrefix = 'L';
    }

    String titleText = descPrefix.isNotEmpty
        ? '${myEvents.title} - $descPrefix'
        : myEvents.title;

    String timeText =
        '${myEvents.stime.format(context)} - ${myEvents.etime.format(context)}';

    bool isQuizEvent = myEvents.desc.toLowerCase().contains("quiz");
    bool isExamEvent = titleText.toLowerCase().contains("exam");


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: isQuizEvent
            ? Colors.red.withOpacity(0.9) // Red for quiz
            : isExamEvent
            ? Colors.purple.withOpacity(0.9) // Purple for exam
            : Theme.of(context).cardColor, // Default card color
        shadowColor: Theme.of(context).shadowColor,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(Icons.event, color: Color(primaryLight)),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Title and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: isQuizEvent || isExamEvent // Set text color based on condition
                              ? Colors.white // If description contains 'quiz', text color is white
                              : Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 12,
                          color: isQuizEvent || isExamEvent
                              ? Colors.white // White text color for 'quiz' events
                              : Colors.grey, // Default grey text color
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Venue
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    myEvents.venue,
                    style: TextStyle(
                      fontSize: 16,
                      color: isQuizEvent
                          ? Colors.white // White text color for 'quiz' events
                          : Colors.grey, // Default grey text color
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eventRow("Description", myEvents.desc, isQuizEvent: isQuizEvent, isExamEvent: isExamEvent),
                    _eventRow("Time", timeText, isQuizEvent: isQuizEvent, isExamEvent: isExamEvent),
                    _eventRow("Venue", myEvents.venue, isQuizEvent: isQuizEvent, isExamEvent: isExamEvent),
                    _eventRow("Host", myEvents.host, isQuizEvent: isQuizEvent, isExamEvent: isExamEvent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//HElper Niga
  Widget _eventRow(String label, String value, {bool isQuizEvent = false, bool isExamEvent = false}) {
    bool isSpecialEvent = isQuizEvent || isExamEvent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: isSpecialEvent ? Colors.white : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isSpecialEvent ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget gettodayEvents() {
    if (todayevents.isEmpty) {
      return const Center(
        child: Text('No events scheduled for today'),
      );
    } else {
      todayevents.sort((a, b) {
        int startComparison = a.stime.hour.compareTo(b.stime.hour);
        if (startComparison != 0) {
          return startComparison;
        } else {
          return a.stime.minute.compareTo(b.stime.minute);
        }
      });
      return Column(
        children: todayevents.map((event) {
          return eventWidget(event);
        }).toList(),
      );
    }
  }



  Widget gettomorrowEvents() {
    if (tomorrowevents.isEmpty) {
      return const Center(
        child: Text('No events scheduled for tomorrow'),
      );
    } else {
      tomorrowevents.sort((a, b) {
        int startComparison = a.stime.hour.compareTo(b.stime.hour);
        if (startComparison != 0) {
          return startComparison;
        } else {
          return a.stime.minute.compareTo(b.stime.minute);
        }
      });
      return Column(
        children: tomorrowevents.map((event) {
          return eventWidget(event);
        }).toList(),
      );
    }
  }






  Widget intermediateText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "What's happening today?",
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  List<Widget> buttons() {
    List<Widget> l = [];

    // Add widgets to the list
    //l.add(ArrowListView());
    l.add(intermediateText());
    l.add(todayEvents());
    l.add(const SizedBox(height: 20));
    l.add(tomorrowEvents());
    l.add(const SizedBox(height: 20));

    return l;
  }
}

class ArrowListView extends StatefulWidget {
  const ArrowListView({Key? key}) : super(key: key);

  @override
  _ArrowListViewState createState() => _ArrowListViewState();
}

class _ArrowListViewState extends State<ArrowListView> {
  String currentMeal = "Dinner";
  int idx = 0;
  final double maxBfTime = toDouble(const TimeOfDay(hour: 9, minute: 30));
  final double maxLunchTime = toDouble(const TimeOfDay(hour: 14, minute: 30));
  double curTime = toDouble(TimeOfDay.now());
  bool showRightArrow = true;
  bool showLeftArrow = false;
  List<String> items = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Menu.fetchMenu(); // Load menu from Firebase
    initItems();
  }

  void initItems() {
    if (curTime < maxBfTime) {
      idx = 0;
      currentMeal = "Breakfast";
    } else if (curTime < maxLunchTime) {
      idx = 1;
      currentMeal = "Lunch";
    } else {
      idx = 2;
      currentMeal = "Dinner";
    }
    items = Menu.menu[getDay()]![idx].description.split(',');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), 
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                initiallyExpanded: false,
                title: Text(
                  'Hungry? See what\'s there for $currentMeal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(primaryLight),
                  ),
                ),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30, 
                        child: Visibility(
                          visible: showLeftArrow,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              _scrollController.animateTo(
                                _scrollController.offset -116,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 110,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: handleScrollNotification,
                            child: ListView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              children: items.map(buildItems).toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30, 
                        child: Visibility(
                          visible: showRightArrow,
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: () {
                              _scrollController.animateTo(
                                _scrollController.offset + 116,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.extentAfter == 0) {
        setState(() {
          showRightArrow = false;
        });
      } else {
        setState(() {
          showRightArrow = true;
        });
      }

      if (notification.metrics.extentBefore == 0) {
        setState(() {
          showLeftArrow = false;
        });
      } else {
        setState(() {
          showLeftArrow = true;
        });
      }
    }
    return true;
  }
}
