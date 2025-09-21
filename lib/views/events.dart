// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:intl/intl.dart';
import 'package:adaptive_theme/adaptive_theme.dart';


//to do build a function to access all the events
class Events extends StatefulWidget {
  final Color appBarBackgroundColor;

  const Events({
    Key? key,
    required this.appBarBackgroundColor,
  }) : super(key: key);

  @override
  State<Events> createState() => _EventsState();
}

class EventCard extends StatefulWidget {
final String eventId;
final String eventTitle;
final String eventType;
final String eventDesc;
final String eventVenue;
final String date;
final String startTime;
final String endTime;
final String? img_url;
final bool isStarred;

const EventCard
({
  super.key,
  required this.eventId,
required this.eventTitle,
required this.eventType,
required this.eventDesc,
required this.eventVenue,
required this.date,
required this.startTime,
required this.endTime,
required this.img_url,
required this.isStarred,
});

@override
_EventCardState createState() => _EventCardState();

}
class _EventCardState extends State<EventCard> {
  late bool _isStarred;
  late String eventTitle;
  late String eventType;
  late String eventDesc;
  late String eventVenue;
  late String date;
  late String startTime;
  late String endTime;
  late String? img_url;
  late String eventId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    _isStarred = widget.isStarred;
    eventTitle = widget.eventTitle;
    eventType = widget.eventType;
    eventDesc = widget.eventDesc;
    eventVenue = widget.eventVenue;
    date = widget.date;
    startTime = widget.startTime;
    endTime = widget.endTime;
    img_url = widget.img_url;
    eventId = widget.eventId;
  }

  Widget build(BuildContext context) {
    double swidth = MediaQuery
        .of(context)
        .size
        .width;
    swidth /= 410;

    return Container(
      padding: EdgeInsets.all(10 * swidth),
      margin: EdgeInsets.all(15 * swidth),
      decoration: BoxDecoration(
          color: Colors.blueGrey[100], borderRadius: BorderRadius.circular(10)),
        //color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(11)),
      child: InkWell(
        onTap: () {
          // Log the URL for debugging.
          print("Image URL: $img_url");

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (img_url != null && img_url!.isNotEmpty)
                      // Wrap in Center to ensure finite constraints.
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 200,
                            child: Image.network(
                              img_url!,
                              fit: BoxFit.cover,
                              // Provide a loading indicator.
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              // Log any errors and show an error widget.
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                print("Error loading image: $error");
                                return Container(
                                  color: Colors.redAccent,
                                  height: 200,
                                  child: const Center(child: Icon(Icons.error)),
                                );
                              },
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventTitle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 26),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Event Type: $eventType",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Description",
                              style:
                              TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 5),
                            Text(eventDesc),
                            const SizedBox(height: 16),
                            const Text(
                              "Venue",
                              style:
                              TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 5),
                            Text(eventVenue),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        },

        child: Row(children: [
          Container(
            padding: EdgeInsets.all(5 * swidth),
            decoration: BoxDecoration(
              color: Colors.amberAccent[100],
              borderRadius: BorderRadius.circular(10),
            ),
            height: 70 * swidth,
            width: 40 * swidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                  child: FittedBox(
                    child: Text(
                      date,style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Ensures black text
                    ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 26,
                  child: FittedBox(
                    child: Text(
                      startTime,
                      style: const TextStyle(fontWeight: FontWeight.bold, color : Colors.black),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 10 * swidth,
          ),
          SizedBox(
            height: 70 * swidth,
            width: 200 * swidth,
// color: Colors.amber,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 26,
                  child: FittedBox(
                    child: Text(
                      eventTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, color : Colors.black,),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 3.69,
                ),
                Flexible(
                    child: Text(
                      eventDesc,
                      overflow: TextOverflow.ellipsis,
                      style : const TextStyle(
                        color : Colors.black,
                      ),
                      maxLines: 2,
                    )),
              ],
            ),
          ),
          SizedBox(
            width: 10 * swidth,
          ),
          Container(
            padding: EdgeInsets.all(5 * swidth),
            decoration: BoxDecoration(
              //color: Theme.of(context).colorScheme.onSurface,
              color: Colors.greenAccent[100],
              borderRadius: BorderRadius.circular(10),
            ),
            height: 70 * swidth,
            width: 70 * swidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 15, child: FittedBox(child: Text(eventType,style: const TextStyle(color: Colors.black)))),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 26,
                  child: FittedBox(
                      child: Text(
                        endTime,
                        style: const TextStyle(fontWeight: FontWeight.bold, color : Colors.black,),
                      )),
                )
              ],
            ),
          ),
          SizedBox(
            width: 5 * swidth,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isStarred = !_isStarred;
              });
              handleStarred(_isStarred,eventId);
            },
            child: Icon(
              _isStarred ? Icons.star : Icons.star_border,
              color: _isStarred ? Colors.purple : Colors.black,
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> handleStarred(bool isStarred,String eventId) async {
    print("handlestarred");
    print(eventId);

    DocumentReference starredCollection = FirebaseFirestore.instance
        .collection("Event.nonrecurring")
        .doc(eventId);
    print(isStarred);

    try {
      print(FirebaseAuth.instance.currentUser!.email!);
      if (isStarred) {
        await starredCollection.update({
          "starredBy": FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.email!]),
        });
      } else if (!isStarred){
        await starredCollection.update({
          "starredBy": FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.email!]),
        });
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}

  Card eventWidget(
      String eventTitle,
      String eventType,
      String eventDesc,
      String eventVenue,
      String date,
      String startTime,
      String endTime,
      String? img_url) {
    return Card(
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              title: Text(eventTitle),
              subtitle: Text(eventType),
              trailing: const Icon(Icons.favorite_outline),
            ),
            Center(
                child: img_url == null
                    ? const SizedBox(height: 20)
                    : Image.network(img_url,
                    errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 20))),
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Venue : $eventVenue',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Desc : $eventDesc',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Date : $date',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Timing : $startTime - $endTime',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }


class _EventsState extends State<Events> {
  DateTime? _selectedDate;
  bool _showStarredEvents = false;
  _EventsState() {
    _selectedDate = DateTime.now();
    _showStarredEvents = false;
  }
  Future<bool> checkIfStarred(String eventId) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
      .collection("Event.nonrecurring")
      .doc(eventId)
      .get();
    if (docSnapshot.exists) {
      var data = docSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('starredBy')) {
        var starredBy = docSnapshot.get("starredBy");
        if (starredBy != null) {
          var currentUserEmail = FirebaseAuth.instance.currentUser!.email;
          return starredBy.contains(currentUserEmail);
        }
      }

    }
    return false;
  }

  String formatDateWord(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date); // Example: Tue, Apr 16, 2024
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: buildTitleBar("EVENTS", context),
          elevation: 0,
          backgroundColor: widget.appBarBackgroundColor,
        ),
        // drawer: const NavDrawer(),
        body: Column(
          children: [
            ListTile(
              title: Text(
                "Show Starred Events",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              subtitle: Text(
                "Toggle to show only starred events",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              trailing: Switch(
                value: _showStarredEvents,
                onChanged: (newValue) {
                  print(newValue);
                  print("toggle");
                  setState(() {
                    _showStarredEvents = newValue;
                  });
                },
                activeColor: Colors.blue, // Color when switch is on
                inactiveThumbColor: Colors.grey[300], // Color of switch when off
                inactiveTrackColor: Colors.grey[400],
              ),

            ),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Event.nonrecurring")
                      .orderBy("eventDate")
                      .snapshots()
                  ,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot> filteredDocs =[];
                      if(_showStarredEvents==true){
                        print("showstarred=true");
                        filteredDocs = snapshot.data!.docs.where((doc) {
                          var data = doc.data() as Map<String, dynamic>?;
                          if (data != null && data.containsKey('starredBy')) {
                            var starredBy = doc.get("starredBy");
                            if (starredBy != null) {
                              var currentUserEmail = FirebaseAuth.instance.currentUser!.email;
                              String doc_eventDate0 = doc.get("eventDate");
                              List<String> date_split = doc_eventDate0.split('/');
                              DateTime doc_eventDate = DateTime(
                                int.parse(date_split[2]),
                                int.parse(date_split[1]),
                                int.parse(date_split[0]),
                              );
                              // print(_selectedDate);
                              // print(doc_eventDate);
                              DateTime endDate = _selectedDate!.add(const Duration(days: 1));
                              DateTime beginDate=_selectedDate!.add(const Duration(days: -1));
                              //print(endDate);
                              //print(starredBy.contains(currentUserEmail) &&((doc_eventDate.isBefore(_selectedDate!) || doc_eventDate.isAtSameMomentAs(_selectedDate!)) && doc_eventDate.isBefore(endDate) && doc_eventDate.isAfter(beginDate)));
                              //return starredBy.contains(currentUserEmail) &&((doc_eventDate.isAfter(_selectedDate!) || doc_eventDate.isAtSameMomentAs(_selectedDate!)) && doc_eventDate.isBefore(endDate));
                              return starredBy.contains(currentUserEmail) &&((doc_eventDate.isBefore(_selectedDate!) || doc_eventDate.isAtSameMomentAs(_selectedDate!)) && doc_eventDate.isBefore(endDate) && doc_eventDate.isAfter(beginDate));
                            }
                            else {return false;}
                          }
                          else {return false;}
                        }).toList();
                      }
                      else{
                        filteredDocs = snapshot.data!.docs.where((doc) {
                          String doc_eventDate0 = doc["eventDate"];
                          List<String> date_split = doc_eventDate0.split('/');
                          DateTime doc_eventDate = DateTime(
                            int.parse(date_split[2]),
                            int.parse(date_split[1]),
                            int.parse(date_split[0]),
                          );
                          DateTime endDate = _selectedDate!.add(const Duration(days: 1));
                          DateTime selectedDateOnly = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                          DateTime docDateOnly = DateTime(doc_eventDate.year, doc_eventDate.month, doc_eventDate.day);
                          return docDateOnly == selectedDateOnly;
                          //return doc_eventDate.isBefore(_selectedDate!.add(const Duration(days: 1))) &&(doc_eventDate.isAfter(_selectedDate!) || doc_eventDate.isAtSameMomentAs(_selectedDate!));
                        }).toList();
                      }

                      filteredDocs.sort((doc1, doc2) {
                        String doc_eventDate1 = doc1["eventDate"];
                        String doc_eventDate2 = doc2["eventDate"];

                        List<String> date_split1 = doc_eventDate1.split('/');
                        List<String> date_split2 = doc_eventDate2.split('/');

                        DateTime date1 = DateTime(
                          int.parse(date_split1[2]),
                          int.parse(date_split1[1]),
                          int.parse(date_split1[0]),
                        );
                        DateTime date2 = DateTime(
                          int.parse(date_split2[2]),
                          int.parse(date_split2[1]),
                          int.parse(date_split2[0]),
                        );

                        int dateComparison = date1.compareTo(date2);

                        if (dateComparison == 0) {
                          // If dates are the same, compare by startTime
                          String startTime1 = doc1["startTime"];
                          String startTime2 = doc2["startTime"];

                          return startTime1.compareTo(startTime2);
                        } else {
                          // Otherwise, compare by eventDate
                          return dateComparison;
                        }
                      });

                      return filteredDocs.isEmpty
                          ? Center(
                        child: Text(
                          "No events for today",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                          ),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = filteredDocs[index];

                          return FutureBuilder<bool>(
                            future: checkIfStarred(doc.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                bool isStarred = snapshot.data!;
                                return EventCard(
                                  eventTitle: doc["eventTitle"],
                                  eventType: doc["eventType"],
                                  eventDesc: doc["eventDesc"],
                                  eventVenue: doc["eventVenue"],
                                  date: doc["eventDate"],
                                  startTime: doc["startTime"],
                                  endTime: doc["endTime"],
                                  img_url: doc["imgURL"],
                                  isStarred: isStarred,
                                  eventId: doc.id,
                                );
                              }
                            },
                          );
                        },
                      );
                      ;
                    } else {
                      return Container();
                    }
                  }),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20), // adds space below the button
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (_selectedDate != null) {
                    _selectedDate = _selectedDate!.subtract(const Duration(days: 1));
                  }
                });
              },
              icon: const Icon(Icons.arrow_left),
            ),
            GestureDetector(
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (selected != null && selected != _selectedDate) {
                  setState(() {
                    _selectedDate = selected;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.appBarBackgroundColor, // match title bar color
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueGrey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate == null
                          ? 'Pick Event Date'
                          : formatDateWord(_selectedDate!),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white, // white text for dark background
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_selectedDate != null) {
                    _selectedDate = _selectedDate!.add(const Duration(days: 1));
                  }
                });
              },
              icon: const Icon(Icons.arrow_right),
            ),
          ],
        ),
      ),

    );

 // Generated code for this Row Widget...
  }
  // Widget themeButtonWidget() {
  //   return IconButton(
  //     onPressed: () {},
  //     icon: const Icon(
  //       Icons.sync_rounded,
  //     ),
  //     color: Colors.white,
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
        const SizedBox(width: 48), // maintain spacing where the icon was
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        signoutButtonWidget(context),
      ],
    );
  }

}
