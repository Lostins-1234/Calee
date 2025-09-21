// ignore_for_file: camel_case_types, no_logic_in_create_state
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/club/add_notification.dart';
import 'package:iitropar/views/club/edit_group.dart';

class ClubNotifications extends StatefulWidget{
  final String clubName;
  const ClubNotifications({super.key,required this.clubName});

  @override
  State<ClubNotifications> createState() => _notificationsScreen(clubName: clubName);

}
class _notificationsScreen extends State<ClubNotifications> {
  _notificationsScreen({required this.clubName});
  final String clubName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("All your Notifications"),
        ),
        body: NotificationsList(clubName: clubName,),
    );
  }
}

class NotificationsList extends StatefulWidget {
  final String clubName;
  const NotificationsList({Key? key, required this.clubName}) : super(key: key);
  @override
  State<NotificationsList> createState() => _NotificationsListState(clubName: clubName);

}
class _NotificationsListState extends State<NotificationsList> {
  final String clubName;
  _NotificationsListState({required this.clubName});

  late Stream<List<Map<String, dynamic>>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    _notificationsStream = FirebaseFirestore.instance
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

      final notificationPromises = groupQuerySnapshot.docs.map((groupDoc) async {
        final eventsQuerySnapshot = await groupDoc.reference.collection('Notifications').get();
        return eventsQuerySnapshot.docs.map((notificationDoc){
          Map<String, dynamic> notifications = notificationDoc.data();
          notifications['id'] = notificationDoc.id;
          return notifications;
        }).toList();
      }).toList();

      final List<List<Map<String, dynamic>>> notificationsList = await Future.wait(notificationPromises);
      return notificationsList.expand((notifications) => notifications).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _notificationsStream,
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

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Stack(
            children:[
              Center(
                  child:Text('No events found for ${widget.clubName}')
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => addNotification(clubName: widget.clubName,)),
                    );
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ],
          );
        }
        return Stack(
          children: [
        ListView.builder(
        itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) {
            final notification = messages[index];
            return Card(
              elevation: 5,
              color: Colors.blueGrey[900],
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(
                  notification['text'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group : ${notification['group']}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Time : ${notification['timeSent']}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Date : ${notification['dateSent']}',
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
                              title: Text('Delete Notification'),
                              content: Text('Are you sure you want to delete this message?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance.collection('Groups')
                                        .doc(notification['group'])
                                        .collection('Notifications')
                                        .doc(notification['id']).delete()
                                        .then((_) {
                                          setState(() {
                                            _fetchNotifications();
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
        ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                backgroundColor: Colors.blueGrey[900],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => addNotification(clubName: widget.clubName,)),
                  );
                },
                child: Icon(Icons.add,color: Colors.white,),
              ),
            ),
          ],
        );

      },
    );
  }
}
