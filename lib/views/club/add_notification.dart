// ignore_for_file: camel_case_types, no_logic_in_create_state
import 'package:iitropar/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iitropar/database/event.dart';

class addNotification extends StatefulWidget {
  const addNotification({super.key, required this.clubName});
  final String clubName;
  @override
  State<addNotification> createState() => _addNotificationState(clubName: clubName);
}

class _addNotificationState extends State<addNotification> {
  _addNotificationState({required this.clubName});
  final String clubName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("$clubName Event"),
        ),
        body: AddNotificationForm(clubName: clubName));
  }
}

// Create a Form widget.
class AddNotificationForm extends StatefulWidget {
  const AddNotificationForm({super.key, required this.clubName});
  final String clubName;

  @override
  AddNotificationFormState createState() {
    return AddNotificationFormState(clubName: clubName);
  }
}

class AddNotificationFormState extends State<AddNotificationForm> {

  final String clubName;

  final _formKey = GlobalKey<FormState>();
  late String message;
  late List<String> clubGroups = [];

  AddNotificationFormState({required this.clubName}) {
    getClubGroups(clubName);
  }
  void getClubGroups(String clubName) async{
    Future<List<String>> groups = firebaseDatabase.getClubGroups(clubName);
    groups.then((List<String> groupList) {
      setState(() {
        clubGroups.addAll(groupList);
      });
    });
  }
  Widget _messageField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Message'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Message is required';
        }
        return null;
      },
      onSaved: (String? value) {
        message = value!;
      },
    );
  }


  String groupName = "";
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _messageField(),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Group is required';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  groupName = value!;
                },
                value: null,
                items: clubGroups
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                })
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    groupName = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Group',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                    }
                    firebaseDatabase.addNotification(
                        message,
                        groupName,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification Added Successfuly')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
