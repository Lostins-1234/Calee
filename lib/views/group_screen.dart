import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/views/groups.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:intl/intl.dart';

class GroupScreen extends StatefulWidget {
  final String groupName;

  const GroupScreen({Key? key, required this.groupName}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondary, // Change to your preferred color
        title: Text(widget.groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Events',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Events',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Groups')
                    .doc(widget.groupName)
                    .collection('Events')
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> eventSnapshot) {
                  if (eventSnapshot.hasError) {
                    return Text('Error: ${eventSnapshot.error}');
                  }

                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<QueryDocumentSnapshot> events = eventSnapshot.data!.docs;

                  // Filter events based on the search query
                  final filteredEvents = events.where((event) {
                    final eventData = event.data() as Map<String, dynamic>;
                    final eventTitle = eventData['eventTitle'].toLowerCase();
                    return eventTitle.contains(_searchQuery);
                  }).toList();

                  return Container(
                    color: Theme.of(context).colorScheme.surface, // Set background color here
                    child: Column(
                      children: filteredEvents.map((event) {
                        final eventData = event.data() as Map<String, dynamic>;
                        return EventCard(
                          eventName: eventData['eventTitle'],
                          eventDate: eventData['eventDate'],
                          eventVenue: eventData['eventVenue'],
                          startTime: eventData['startTime'],
                          endTime: eventData['endTime'],
                          eventDesc: eventData['eventDesc'],
                          groupName: widget.groupName,
                        );
                      }).toList(),
                    ),
                  );

                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Groups')
                    .doc(widget.groupName)
                    .collection('Notifications')
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> notificationSnapshot) {
                  if (notificationSnapshot.hasError) {
                    return Text('Error: ${notificationSnapshot.error}');
                  }

                  if (notificationSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<QueryDocumentSnapshot> notifications = notificationSnapshot.data!.docs;

                  return Column(
                    children: notifications.map((notification) {
                      final notificationData = notification.data() as Map<String, dynamic>;
                      return NotificationCard(
                        notificationType: notificationData['text'],
                        timeSent: '${notificationData['dateSent']} | ${notificationData['timeSent']}',
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('Groups');
                  groupsCollection.doc(widget.groupName).collection('Users').doc(user!.email).delete();
                  Navigator.pop(context, true);
                  //Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=> Groups()), (route)=>false,);
                  // _showConfirmationDialog(context, widget.groupName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Background color
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0), // Increased padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded corners
                  ),
                  elevation: 6.0, // Elevation for a shadow effect
                  textStyle: const TextStyle(
                    fontSize: 16.0, // Increased font size
                    fontWeight: FontWeight.bold, // Bolder font weight
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.exit_to_app, // Icon for leaving the group
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.0), // Space between icon and text
                    Text(
                      'Leave Group',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showConfirmationDialog(BuildContext context, String groupName) async {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('Groups');

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Leave Group'),
        content: Text('Are you sure you want to leave the group "$groupName"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              groupsCollection.doc(groupName).collection('Users').doc(user!.email).delete().then((_) {
                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => Groups()), (route) => false);
              }).catchError((error) {
                print("**************** ${error} ********************");
              });

              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('No'),
          ),
        ],
      );
    },
  );
}

class EventCard extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String eventVenue;
  final String startTime;
  final String endTime;
  final String eventDesc;
  final String groupName;

  const EventCard({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.eventVenue,
    required this.startTime,
    required this.endTime,
    required this.eventDesc,
    required this.groupName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $eventDate'),
            Text('Venue: $eventVenue'),
            Text('Start Time: $startTime'),
            Text('End Time: $endTime'),
            Text('Description: $eventDesc'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(onPressed: () {
                print("add to calender");
                print(eventName);
                print(eventDesc);
                print(eventVenue);
                print(groupName);
                addEvent(eventName, eventDesc, eventVenue, groupName, startTime, endTime, eventDate);
              }, icon: const Icon(Icons.add), label: Text('Add to calendar'))
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String notificationType;
  final String timeSent;

  const NotificationCard({
    Key? key,
    required this.notificationType,
    required this.timeSent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(notificationType),
        subtitle: Text(timeSent),
      ),
    );
  }
}

void addEvent(eventTitle, eventDesc, eventVenue, groupName, startTime, endTime, eventDate) async {
  final User? user = FirebaseAuth.instance.currentUser;
  print("in func");
  print(eventTitle);
  print(startTime);
  print(endTime);

  Event event = Event(
    title: eventTitle,
    desc: eventDesc,
    stime: TimeOfDay.fromDateTime(DateFormat.Hm().parse(startTime)),
    etime: TimeOfDay.fromDateTime(DateFormat.Hm().parse(endTime)),
    creator: user!.email ?? "guest",
    venue: eventVenue,
    host: groupName
  );
  print(event.stime);
  print(event.etime);

  List<String> parts = eventDate.split('/');
  int day = int.parse(parts[0]);
  int month = int.parse(parts[1]);
  int year = int.parse(parts[2]);
  DateTime eDate = DateTime(year, month, day); // Set the date of the event

  // Create an instance of EventDB and call the addSingularEvent method
  EventDB eventDB = EventDB();
  await eventDB.addSingularEvent(event, eDate);
}
