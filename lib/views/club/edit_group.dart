// ignore_for_file: camel_case_types, no_logic_in_create_state
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iitropar/database/event.dart';

class editClubGroup extends StatefulWidget {
  const editClubGroup({super.key, required this.groupName,required this.groupDesc, required this.groupType});
  final String groupName;
  final String groupDesc;
  final String groupType;
  @override
  State<editClubGroup> createState() => _editClubGroupState(groupName: groupName,
  groupDesc:groupDesc,
  groupType:groupType);
}

class _editClubGroupState extends State<editClubGroup> {
  _editClubGroupState({required this.groupName,required this.groupDesc, required this.groupType});
  final String groupName;
  final String groupDesc;
  final String groupType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Edit $groupName'),
        ),
        body: editGroupForm(groupName: groupName,
            groupDesc:groupDesc,
            groupType:groupType));
  }
}

// Create a Form widget.
class editGroupForm extends StatefulWidget {
  const editGroupForm({super.key, required this.groupName,required this.groupDesc, required this.groupType});
  final String groupName;
  final String groupDesc;
  final String groupType;

  @override
  editGroupFormState createState() {
    return editGroupFormState(groupName: groupName,
        groupDesc:groupDesc,
        groupType:groupType);
  }
}
// This class holds data related to the form.
class editGroupFormState extends State<editGroupForm> {

  final _formKey = GlobalKey<FormState>();
  late String groupName;
  late String groupDesc;
  late String groupType;

  editGroupFormState({required this.groupName,required this.groupDesc, required this.groupType}) {
    groupName = groupName;
    groupType = groupType;
    groupDesc = groupDesc;
  }
  Widget _buildGroupDesc() {
    return TextFormField(
      initialValue: groupDesc,
      maxLines: 1,
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
                value: groupType,
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
                          _formKey.currentState!.save();
                        }
                        firebaseDatabase.modifyClubGroup(
                          groupName,
                          groupDesc,
                          groupType,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Group details changed Successfully')),
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
