// ignore_for_file: camel_case_types, no_logic_in_create_state
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/club/edit_group.dart';
import 'package:iitropar/views/club/group_members.dart';

class ManageMembersScreen extends StatefulWidget{
  final String clubName;
  const ManageMembersScreen({super.key,required this.clubName});

  @override
  State<ManageMembersScreen> createState() => _manageMembersScreen(clubName: clubName);

}
class _manageMembersScreen extends State<ManageMembersScreen> {
  _manageMembersScreen({required this.clubName});
  final String clubName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Manage Members"),
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
            if(data['groupType'] == "Public" || data['associatedClub'] != clubName) return Container();
            return Card(
                elevation: 2,
                color: Colors.blueGrey[900],
                margin: const EdgeInsets.all(10),
              child:ListTile(
              title: Text('$documentId',
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,),
              subtitle: Text(data['groupDesc'],
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,),
                onTap: (){
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => groupMembersScreen(groupName: document.id,)),
                );
                },
            ));
          },
        );
      },
    );
  }
}

