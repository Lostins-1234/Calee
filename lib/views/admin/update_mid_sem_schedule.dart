// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'dart:convert';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:path/path.dart' as p;

class updateMidSemSchedule extends StatefulWidget {
  const updateMidSemSchedule({super.key});

  @override
  State<updateMidSemSchedule> createState() => _updateCoursesState();
}

class _updateCoursesState extends State<updateMidSemSchedule> {
  String? filePath;

  Future<void> uploadCSVToFirebase(File file, String fileName) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);

    SettableMetadata metadata = SettableMetadata(contentType: "text/csv");


    UploadTask uploadTask = storageReference.putFile(file, metadata);


    await uploadTask;
    // Get current timestamp
    Timestamp timestamp = Timestamp.now();

    // Store in Firestore under collection 'Timestamp'
    await FirebaseFirestore.instance.collection('Timestamp').doc(fileName).set({
      'timestamp': timestamp,
    });
  }

  void _pickFile(ScaffoldMessengerState sm) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false,);

    // if no file is picked
    if (result == null) return;
    filePath = result.files.first.path!;
    File file = File(result.files.single.path!);
    if(result.files.single.extension != 'csv') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select only a csv file.'),
        ),
      );
    }
    try {
      String fileName = 'MidSemTable.csv';
      await uploadCSVToFirebase(file, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading file.'),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Color(secondaryLight),
          automaticallyImplyLeading: false,
          title: buildTitleBar("UPDATE MID-SEM SCHEDULE", context),
        ),
        body: Column(children: [
          const SizedBox(height: 50),
          const Text('Accepted CSV format is given below',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset('assets/midSemSample.png'),
          ),
          const SizedBox(height: 5),
          const Text(
            'Ensure that you enter valid course and slot codes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const Text(
            'Note : Do not include the headers !',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Color(primaryLight)),
            ),
            child: const Text("Upload File",
              style: TextStyle(color: Colors.white),),
            onPressed: () {
              _pickFile(ScaffoldMessenger.of(context));
            },
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Color(primaryLight)),
            ),
            child: const Text("Download Sample",
              style: TextStyle(color: Colors.white),),
            onPressed: () async {
              final result = await FilePicker.platform.getDirectoryPath();
              if (result == null) {
                return;
              }
              File nfile = File(p.join(result, 'MidSemTimeTableSample.csv'));
              nfile.writeAsString(
                  await rootBundle.loadString('assets/MidSemTable.csv'));
            },
          ),
        ]));
  }
  Widget themeButtonWidget() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        Icons.arrow_back,
      ),
      color: Color(primaryLight),
      iconSize: 28,
    );
  }

  TextStyle appbarTitleStyle() {
    return TextStyle(
        color: Color(primaryLight),
        // fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5);
  }

  Row buildTitleBar(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        themeButtonWidget(),
        Flexible(
          child: SizedBox(
            height: 30,
            child: FittedBox(
              child: Text(
                text,
                style: appbarTitleStyle(),
              ),
            ),
          ),
        ),
        signoutButtonWidget(context),
      ],
    );
  }
}
