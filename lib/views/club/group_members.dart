// ignore_for_file: camel_case_types, no_logic_in_create_state
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/club/add_members.dart';


class groupMembersScreen extends StatefulWidget{
  final String groupName;
  const groupMembersScreen({super.key,required this.groupName});

  @override
  State<groupMembersScreen> createState() => _groupMembersScreen(groupName: groupName);

}
class _groupMembersScreen extends State<groupMembersScreen> {
  _groupMembersScreen({required this.groupName});
  final String groupName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('${groupName} Members',maxLines: 1,),
        ),
        body: GroupList(groupName:groupName),
    );
  }
}

class GroupList extends StatefulWidget {
  final String groupName;
  
  const GroupList({required this.groupName});
  
  @override
  State<GroupList> createState() => _GroupListState(groupName:groupName);

}
class _GroupListState extends State<GroupList> {
  
  _GroupListState({required this.groupName});
  final String groupName;
  Set<dynamic> courses = {"hello"};
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Groups').doc(groupName).collection('Users').snapshots(),
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

        List<DocumentSnapshot> members = snapshot.data!.docs;

        return Stack(children:[ListView.builder(
        itemCount: members.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = members[index];
            String documentId = document.id;
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return Card(
                elevation: 5,
                color: Colors.blueGrey[900],
                margin: const EdgeInsets.all(10),
                child:ListTile(
                  title: Text(documentId,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      Icon(
                        Icons.account_box_rounded,
                        color: Colors.blue[100],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      IconButton(
                        icon: Icon(Icons.delete,color: Colors.red[200],),
                        onPressed: () {
                          // Show dialog for confirmation before deleting
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Remove user'),
                                content: Text('Are you sure you want to remove this user?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Delete the group from Firestore
                                      FirebaseFirestore.instance.collection('Groups')
                                          .doc(groupName)
                                          .collection('Users')
                                          .doc(document.id)
                                          .delete();
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
        ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              backgroundColor: Colors.blueGrey[700],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => addMembers(groupName:groupName)),
                );
              },
              child: Icon(Icons.add,color: Colors.white,),
            ),
          ),
        ]);
      },
    );
  }
}
