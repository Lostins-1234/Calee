// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names, no_logic_in_create_state

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/database/loader.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:iitropar/views/faculty/seeSlots.dart';

//to do build a function to access all the events
class addMembers extends StatefulWidget {
  final String groupName;
  addMembers({super.key,required this.groupName});

  @override
  State<addMembers> createState() => _addMembersState(groupName:groupName);
}

class _addMembersState extends State<addMembers> {
  Set<String> memberEmails = {};
  bool inputFormat = true;
  final String groupName;
  TextEditingController emailInput = TextEditingController();

  _addMembersState({required this.groupName});

  bool verifyHeader(List<dynamic> csv_head) {
    if (csv_head.isEmpty) {
      return false;
    }
    String header = csv_head[0].toLowerCase();
    if (header.compareTo("memberemails") == 0 ||
        header.compareTo("member emails") == 0) {
      return true;
    }
    return false;
  }

  Future<bool> checkEmails(String email) async {
    RegExp regex = RegExp(r"^[0-9]{4}[a-z]{3}[0-9]{4}@iitrpr\.ac\.in$");
    if (regex.hasMatch(email)) {
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Email id ${emailInput.text} is not valid")));
    return false;
  }

  void getStudentsCSV(List<dynamic> fields) async {
    inputFormat = true;
    Set<String> emails = {};
    for (int i = 1; i < fields.length; i++) {
      String memberEmail = fields[i][0].toString();
      if (await checkEmails(memberEmail.toLowerCase())) {
        emails.add(memberEmail);
      } else {
        inputFormat = false;
      }
    }
    setState(() {
      memberEmails = emails;
    });
  }

  void _pickFile(ScaffoldMessengerState sm) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    String filePath = result.files.first.path!;

    final input = File(filePath).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    if (!verifyHeader(fields[0])) {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv incorrect!")));
    } else {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv correct!")));
      getStudentsCSV(fields);
    }
  }

  Widget addSingleMember() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextFormField(
            controller: emailInput,
            decoration: const InputDecoration(
                icon: Icon(Icons.description),
                labelText: "Enter EmailId"),
          )),
      IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            if (await checkEmails(emailInput.text.toLowerCase())) {
              setState(
                () {
                  memberEmails.add(emailInput.text);
                  emailInput.clear();
                },
              );
            } else {}
          }),
    ]);
  }

  Widget getCSVscreen() {
    return Center(
        child: ElevatedButton(
      onPressed: () {
        // Show an alert dialog with a confirmation prompt
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Given CSV format'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset('assets/faculty_entryNumber.png'),
                    ),
                    const Text('1. Email should be valid.')
                  ],
                ),
              ),
              actions: <Widget>[
                Center(
                  child: ElevatedButton(
                    child: const Text('Upload File'),
                    onPressed: () {
                      // Close the dialog and call the onPressed function
                      _pickFile(ScaffoldMessenger.of(context));
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      // Close the dialog and do nothing
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
      ),
      child: const Text('Upload via CSV',
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  Widget getStudents() {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 0.25,
            color: Color(primaryLight).withOpacity(0.5),
          ),
          const Text('Add Member'),
          addSingleMember(),
          // const SizedBox(height: 10),
          Divider(
            thickness: 0.25,
            color: Color(primaryLight).withOpacity(0.5),
          ),
          // const SizedBox(height: 10),
          getCSVscreen(),
          Divider(
            thickness: 2,
            color: Color(primaryLight).withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget showSelectedStudents() {
    return Column(
      children: [
        const Text(
          'Selected EmailIds',
          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
          child: ListView.builder(
              itemCount: memberEmails.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          memberEmails.remove(memberEmails.elementAt(index));
                        });
                      },
                    ),
                    title: memberEmails.elementAt(index) == null
                        ? Text('${memberEmails.elementAt(index)})')
                        : Text(
                            '${memberEmails.elementAt(index)}')); // todo: do via map loaded in frequency used.
              }),
        ),
      ],
    );
  }

  Widget submitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          if (memberEmails.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Add atleast one member")),
            );
            return;
          }
          firebaseDatabase.addClubMembers(
            groupName,
            memberEmails
          );
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add members to group'),
                content: Text('Selected users have been added to the group ${groupName}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        },
        child: const Text('Submit'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName,
          maxLines: 1,
        ),
      ),
      // drawer: const NavDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getStudents(),
            showSelectedStudents(),
            divider(),
            submitButton(),
          ],
        ),
      ),
    );
  }
}
