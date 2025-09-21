// ignore_for_file: camel_case_types, no_logic_in_create_state
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/club/edit_group.dart';

class ManageGroupsScreen extends StatefulWidget{
  final String clubName;
  const ManageGroupsScreen({super.key,required this.clubName});

  @override
  State<ManageGroupsScreen> createState() => _manageGroupsScreen(clubName: clubName);

}
class _manageGroupsScreen extends State<ManageGroupsScreen> {
  _manageGroupsScreen({required this.clubName});
  final String clubName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Manage Groups"),
        ),
        body: GroupList(clubName: clubName,),
    );
  }
}

class GroupList extends StatefulWidget {
  final String clubName;
  const GroupList({super.key,required this.clubName});
  @override
  State<GroupList> createState() => _GroupListState(clubName: clubName);

}
class _GroupListState extends State<GroupList> {
  final String clubName;
  _GroupListState({required this.clubName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Groups').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<DocumentSnapshot> groups = snapshot.data!.docs;

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = groups[index];
            String documentId = document.id;
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            if(data['associatedClub'] != clubName) return Container();

            return Card(
                elevation: 5,
                color: Colors.blueGrey[900],
                margin: const EdgeInsets.all(10),
              child:ListTile(
              title: Text('$documentId',
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,),
              subtitle: Text(data['groupDesc'],
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(color: Colors.grey),),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
              children:[
                IconButton(
                  icon: Icon(Icons.edit,color: Colors.blue[100],),
                  onPressed: () {
                    // Navigate to edit group screen
                    // Pass the document ID for editing
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => editClubGroup(groupName: document.id,groupDesc: data["groupDesc"],groupType: data["groupType"])),
                    );
                  },
                ),
                IconButton(
                icon: Icon(Icons.delete,color: Colors.red[200],),
                onPressed: () {
                  // Show dialog for confirmation before deleting
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Group'),
                        content: Text('Are you sure you want to delete this group?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Delete the group from Firestore
                              FirebaseFirestore.instance.collection('Groups').doc(document.id).delete();
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
            ));
          },
        );
      },
    );
  }
}

class EditGroupScreen extends StatelessWidget {
  final String documentId;

  EditGroupScreen({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Group'),
      ),
      body: Center(
        child: Text('Edit group with document ID: $documentId'),
      ),
    );
  }
}
