import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/views/group_screen.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  List<Map<String, String>> availableGroups = [];
  List<Map<String, String>> joinedGroups = [];

  Future<void> refreshGroups() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance.collection('Groups').get();
    await _processDocuments(snapshot.docs, user);
    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: Color(0xFF0D47A1), // Change to your preferred color
        title: buildTitleBar("CLUB GROUPS", context),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Groups').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          //_processDocuments(documents, user);
          return FutureBuilder<void>(
            future: _processDocuments(documents, user),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                children: [
                  _buildGroupList('Groups Joined', joinedGroups, context),
                  _buildGroupList('Groups Available', availableGroups, context),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _processDocuments(List<DocumentSnapshot> documents, User? user) async {
    // Clear the lists before updating
    availableGroups.clear();
    joinedGroups.clear();
    // Process each document asynchronously
    await Future.forEach(documents, (DocumentSnapshot doc) async {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        return;
      }
      DocumentSnapshot userDoc = await doc.reference.collection('Users').doc(user!.email).get();
      if (userDoc.exists) {
        joinedGroups.add({
          'groupName': data['groupName'] ?? "<Group Name>",
          'associatedClub': data['associatedClub'] ?? "<Club Name>"
        });
      } else if (data['groupType'] == 'Public') {
        availableGroups.add({
          'groupName': data['groupName'] ?? "<Group Name>",
          'associatedClub': data['associatedClub'] ?? "<Club Name>"
        });
      }
    });
  }

  Widget _buildGroupList(String category, List<Map<String, String>> groups, BuildContext context) {
    return groups.isNotEmpty
        ? Column(
      children: [
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent, // removes the bottom black line
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: category == 'Groups Joined',
              backgroundColor: Theme.of(context).colorScheme.surface, // Adaptive background
              collapsedBackgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color, //  Adaptive text color
                ),
              ),
              iconColor: Theme.of(context).iconTheme.color, // Adaptive icon
              collapsedIconColor: Theme.of(context).iconTheme.color,
              leading: Icon(Icons.group, color: Theme.of(context).iconTheme.color),
              children: groups.map((group) {
                return InkWell(
                  onTap: () async {
                    if (category == "Groups Available") {
                      _showConfirmationDialog(context, group['groupName'] ?? "<Group Name>");
                    } else {
                      bool? leftGroup = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupScreen(groupName: group['groupName'] ?? "<Group Name>"),
                        ),
                      );
                      if (leftGroup == true) {
                        await refreshGroups();
                      }
                    }
                  },
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group['groupName'] ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary, // Adaptive color
                          ),
                        ),
                        Text(
                          group['associatedClub'] ?? "",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

      ],
    ): Column(
      children: [
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: Icon(Icons.group, color: Theme.of(context).iconTheme.color),
            title: Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text("No groups to show"),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, String groupName) async {
    final User? user = await FirebaseAuth.instance.currentUser;
    final CollectionReference groupsCollection = await FirebaseFirestore.instance.collection('Groups');

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Join Group'),
          content: Text('Are you sure you want to join the group "$groupName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Map<String, dynamic> newDoc = {
                  'email': user!.email,
                };
                groupsCollection.doc(groupName).collection('Users').doc(user.email).set(newDoc).then((_) {
                  setState(() {});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupScreen(groupName: groupName),
                    ),
                  );
                }).catchError((error) {
                  // Handle error
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

  Row buildTitleBar(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: refreshGroups,
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => Groups()),
            // );
          // },
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

  Widget themeButtonWidget() {
    return IconButton(
      onPressed: () {},
      icon: const Icon(
        Icons.sync_rounded,
      ),
      color: Color(primaryLight),
      iconSize: 28,
    );
  }

  TextStyle appbarTitleStyle() {
    return TextStyle(
      color: Color(primaryLight),
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    );
  }
}
