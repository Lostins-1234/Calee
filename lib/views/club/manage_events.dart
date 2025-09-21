// ignore_for_file: camel_case_types, no_logic_in_create_state
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/club/edit_group.dart';

class ManageEvents extends StatefulWidget{
  final String clubName;
  const ManageEvents({super.key,required this.clubName});

  @override
  State<ManageEvents> createState() => _manageEventsScreen(clubName: clubName);

}
class _manageEventsScreen extends State<ManageEvents> {
  _manageEventsScreen({required this.clubName});
  final String clubName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("All your events"),
        ),
        body: EventList(clubName: clubName,),
    );
  }
}

class EventList extends StatefulWidget {
  final String clubName;
  const EventList({Key? key, required this.clubName}) : super(key: key);
  @override
  State<EventList> createState() => _EventListState(clubName: clubName);

}
class _EventListState extends State<EventList> {
  final String clubName;
  _EventListState({required this.clubName});

  late Stream<List<Map<String, dynamic>>> _eventsStream;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() {
    _eventsStream = FirebaseFirestore.instance
        .collection('Groups')
        .where('associatedClub', isEqualTo: widget.clubName)
        .snapshots()
        .asyncMap((clubQuerySnapshot) async {
      if (clubQuerySnapshot.docs.isEmpty) {
        return [];
      }

      final groupQuerySnapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .where('associatedClub', isEqualTo: widget.clubName)
          .get();

      final eventPromises = groupQuerySnapshot.docs.map((groupDoc) async {
        final eventsQuerySnapshot = await groupDoc.reference.collection('Events').get();
        return eventsQuerySnapshot.docs.map((eventDoc){
          // Include the document ID in the event data
          Map<String, dynamic> eventData = eventDoc.data();
          eventData['id'] = eventDoc.id;
          return eventData;
        }).toList();
      }).toList();

      final List<List<Map<String, dynamic>>> eventsList = await Future.wait(eventPromises);
      return eventsList.expand((events) => events).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _eventsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return Center(
            child: Text('No events found for ${widget.clubName}'),
          );
        }
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            final event = events[index];
            return Card(
              elevation: 5,
              color: Colors.blueGrey[900],
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(
                  event['eventTitle'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['eventDesc'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Time created: ${event['created']}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Group: ${event['group']}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete,color: Colors.red[200],),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Event'),
                              content: Text('Are you sure you want to delete this event?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Add your delete functionality here
                                    FirebaseFirestore.instance.collection('Groups')
                                        .doc(event['group'])
                                        .collection('Events')
                                        .doc(event['id']).delete()
                                        .then((_) {
                                          setState(() {
                                            _fetchEvents();
                                          });
                                        });
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );

      },
    );
  }
}
