// ignore_for_file: file_names, camel_case_types, sort_child_properties_last

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class registerFaculty extends StatefulWidget {
  const registerFaculty({super.key});

  @override
  State<registerFaculty> createState() => _registerFacultyState();
}

class _registerFacultyState extends State<registerFaculty> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          automaticallyImplyLeading: false,
          //backgroundColor: const Color(0xFF0D47A1),
          title: buildTitleBar("REGISTER FACULTY", context),
        ),
        body: const AddEventForm());
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

// Create a Form widget.
class AddEventForm extends StatefulWidget {
  const AddEventForm({super.key});

  @override
  AddEventFormState createState() {
    return AddEventFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class AddEventFormState extends State<AddEventForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.

  final _formKey = GlobalKey<FormState>();
  late String facultyName;
  late String facultyDep;
  late String facultyEmail;
  late Set<String> facultyCourses;
  List<List<dynamic>> _data = [];
  String? filePath;
  TextEditingController coursesInput = TextEditingController();
  AddEventFormState() {
    facultyCourses = {};
    facultyEmail = "";
    facultyName = "";
    facultyDep = "Computer Science & Engineering";
  }
  Widget _buildFacultyName() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Faculty Name'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Faculty Name is required';
        }
        return null;
      },
      onSaved: (String? value) {
        facultyName = value!;
      },
    );
  }

  Widget _buildFacultyEmail() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Faculty Email'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Faculty Email is required';
        } else if (!formChecks.email_check(value) && value != "testfaculty001@gmail.com") {
          return 'Enter valid email ID and IDs not being used';
        }
        return null;
      },
      onSaved: (String? value) {
        facultyEmail = value!;
      },
    );
  }

  Widget _buildFacultyDep() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Department',
            textAlign: TextAlign.left,
          ),
          DropdownButton(
            isExpanded: true,
            items: departments,
            value: facultyDep,
            onChanged: (value) {
              setState(() {
                facultyDep = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  bool validCourse(String courseCode) {
    String _courseCode = courseCode.replaceAll(' ', '');
    return allCourses.contains(_courseCode.toUpperCase());
  }

  bool validDep(String dep) {
    for (int i = 0; i < departments.length; i++) {
      if (dep == departments[i].value) return true;
    }
    return false;
  }

  String getDep(String dep) {
    dep = dep.toLowerCase();
    dep = dep.replaceAll(' ', '');
    if (dep == "cse" ||
        dep == "csb" ||
        dep == "ComputerScience&Engineering".toLowerCase())
      return "Computer Science & Engineering";
    else if (dep == "eeb" ||
        dep == "ee" ||
        dep == "ElectricalEngineering".toLowerCase())
      return "Electrical Engineering";
    else if (dep == "chb" || dep == "ChemicalEngineering".toLowerCase())
      return "Chemical Engineering";
    else if (dep == "bme" || dep == "BioMedicalEngineering".toLowerCase())
      return "BioMedical Engineering";
    else if (dep == "mme" ||
        dep == "MetallurgicalandMaterialsEngineering".toLowerCase())
      return "Metallurgical and Materials Engineering";
    else if (dep == "ceb" || dep == "CivilEngineering".toLowerCase())
      return "Civil Engineering";
    else if (dep == "chemistry" || dep == "chem")
      return "Chemistry";
    else if (dep == "physics")
      return "Physics";
    else if (dep == "mathematics")
      return "Mathematics";
    else if (dep == "HumanitiesandSocialSciences".toLowerCase())
      return "Humanities and Social Sciences";
    else if (dep == "MechanicalEngineering".toLowerCase())
      return "Mechanical Engineering";
    return "other";
  }

  Widget _buildRemoveCourses() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: facultyCourses
              .map(
                (course) => Chip(
                  label: Text(course),
                  deleteIcon: const Icon(Icons.clear),
                  onDeleted: () {
                    setState(() {
                      facultyCourses.remove(course);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFacultyCourses() {
    List<String> courses;
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: TextFormField(
                controller: coursesInput,
                decoration: const InputDecoration(
                    icon: Icon(Icons.school), labelText: "Enter Courses "),
              )),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                if (validCourse(coursesInput.text)) {
                  setState(() {
                    facultyCourses.add(
                        coursesInput.text.toUpperCase().replaceAll(' ', ''));
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("CourseCode not valid.")),
                  );
                }
              }),
        ]),
      ],
    );
  }

  void uploadData(List<List<dynamic>> f) async {
    int len = f.length;
    for (int i = 1; i < len; i++) {
      String dep = f[i][2];
      if (!validDep(f[i][2])) {
        dep = getDep(dep);
      }
      Set<String> courses = {};
      int attrs = f[i].length;
      for (int j = 3; j < attrs; j++) {
        if (validCourse(f[i][j].toString())) {
          courses.add(f[i][j].toString().toUpperCase().replaceAll(' ', ''));
        } //invalid courses are rejected
      }
      faculty fac = faculty(f[i][0], f[i][1], dep, courses);
      firebaseDatabase.registerFacultyFB(fac);
    }
  }

  void _pickFile(ScaffoldMessengerState sm) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    //print(result.files.first.name);
    filePath = result.files.first.path!;

    final input = await File(filePath!).readAsString(encoding: utf8);
    print("hello");
    print(input);
    print("3hjwq");
    final fields = const CsvToListConverter(eol: '\n').convert(input);
    // final fields = await input
    //     .transform(utf8.decoder)
    //     .transform(const CsvToListConverter())
    //     .toList();
    print(fields[0]);
    if (!verifyHeader(fields[0])) {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv incorrect!")));
    } else {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv correct!")));
      uploadData(fields);
    }
    setState(() {
      _data = fields;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data Added with CSV")),
    );
  }

  bool verifyHeader(List<dynamic> header) {
    if (header[0].toString().toLowerCase() == "email" &&
        header[1].toString().toLowerCase() == "facultyname" &&
        header[2].toString().toLowerCase() == "department" &&
        header[3].toString().toLowerCase() == "courses")
        return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.all(20),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFacultyName(),
                const SizedBox(
                  height: 20,
                ),
                _buildFacultyDep(),
                _buildFacultyEmail(),
                const SizedBox(
                  height: 20,
                ),
                _buildFacultyCourses(),
                const SizedBox(
                  height: 20,
                ),
                _buildRemoveCourses(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      style:ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          _formKey.currentState!.save();
                          String espcl =
                              await firebaseDatabase.emailCheck(facultyEmail);
                          if (espcl == "faculty" || espcl == "club") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Email already taken by $espcl")),
                            );
                            return;
                          }
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmation'),
                                  content: Text(
                                      "Are you sure you want to add faculty $facultyName ?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        // Close the dialog and do nothing
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ElevatedButton(
                                      child: const Text('Submit'),
                                      onPressed: () {
                                        faculty f = faculty(
                                            facultyEmail,
                                            facultyName,
                                            facultyDep,
                                            facultyCourses);

                                        firebaseDatabase.registerFacultyFB(f);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Faculty has been registered!")),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      },
                      child: const Text('Submit',
                      style: TextStyle(
                        color: Colors.white
                      ),),
                    ),
                  ),
                ),
                const Center(
                    child: Text(
                  'OR',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Show an alert dialog with a confirmation prompt
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Given CSV format'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Image.asset("assets/faculty_register.png"),
                                  const SizedBox(height: 10),
                                  const Text(
                                    '1. All faculty must have a unique email ID',
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    '2. Course Code must be valid.',
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    '3. Department should be valid',
                                    textAlign: TextAlign.left,
                                  ),
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
                              Center(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                  //backgroundColor: const ,
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Color(primaryLight)),
                                   ),
                                  child: const Text("Download Sample"),
                                  onPressed: () async {
                                    final result = await FilePicker.platform
                                        .getDirectoryPath();
                                    if (result == null) {
                                      return;
                                    }
                                    File nfile = File(
                                        p.join(result, 'faculty_sample.csv'));
                                    nfile.writeAsString(
                                        await rootBundle.loadString(
                                            'assets/facultySample.csv'));
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
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Upload via CSV',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
