// ignore_for_file: camel_case_types, no_logic_in_create_state
import 'package:iitropar/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iitropar/database/event.dart';



class addClubGroup extends StatefulWidget {
  const addClubGroup({super.key, required this.clubName});
  final String clubName;
  @override
  State<addClubGroup> createState() => _addClubGroupState(clubName: clubName);
}

class _addClubGroupState extends State<addClubGroup> {
  _addClubGroupState({required this.clubName});
  final String clubName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("New Group"),
        ),
        body: AddClubForm(clubName: clubName));
  }
}

// Create a Form widget.
class AddClubForm extends StatefulWidget {
  const AddClubForm({super.key, required this.clubName});
  final String clubName;

  @override
  AddClubFormState createState() {
    return AddClubFormState(clubName: clubName);
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class AddClubFormState extends State<AddClubForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final String clubName;

  final _formKey = GlobalKey<FormState>();
  late String groupName;
  late String groupDesc;
  late String groupType;

  AddClubFormState({required this.clubName}) {
    groupDesc = clubName;
  }
  Widget _buildGroupName() {
    return TextFormField(
      maxLines: 1,
      decoration: const InputDecoration(labelText: 'Group Name'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Group Name is required';
        }
        return null;
      },
      onSaved: (String? value) {
        groupName = value!;
      },
    );
  }

  Widget _buildGroupDesc() {
    return TextFormField(
      maxLines: 2,
      decoration: const InputDecoration(labelText: 'Group Description'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Group Description is required';
        }
        return null;
      },
      onSaved: (String? value) {
        groupDesc = value!;
      },
    );
  }
  String dropdownValue="Private";
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
              _buildGroupName(),
              _buildGroupDesc(),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Group type is required';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  groupType = value!;
                },
                value: dropdownValue,
                items: ["Public", "Private"]
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                })
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Group Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.black),),
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          _formKey.currentState!.save();
                        }
                        firebaseDatabase.addClubGroup(
                          groupName,
                          groupDesc,
                          groupType,
                          clubName,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Group Created Successfully')),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Submit',
                      style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
