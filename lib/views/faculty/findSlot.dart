// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names, no_logic_in_create_state

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
class findSlots extends StatefulWidget {
  late Set<dynamic> courses;
  findSlots(this.courses);

  @override
  State<findSlots> createState() => _findSlotsState(courses);
}

class _findSlotsState extends State<findSlots> {
  late Set<dynamic> courses;
  String? current_course = null;
  _findSlotsState(this.courses) {
    getMapping();
  }
  Set<String> students = {};
  int slotLength = 1;
  bool inputFormat = true;
  DateTime date = DateTime.now();
  TextEditingController entryInput = TextEditingController();
  Map<String, String> entryToName = {};
  getMapping() async {
    entryToName = await firebaseDatabase.getNameMapping();
    setState(() {});
  }

  bool verifyHeader(List<dynamic> csv_head) {
    if (csv_head.isEmpty) {
      return false;
    }
    String header = csv_head[0].toLowerCase();
    if (header.compareTo("entrynumber") == 0 ||
        header.compareTo("entry number") == 0) {
      return true;
    }
    return false;
  }

  Future<bool> checkEntryNumber(String entryNumber) async {
    RegExp regex = RegExp(r"^[0-9]{4}[a-z]{3}[0-9]{4}$");
    if (regex.hasMatch(entryNumber)) {
      bool check = await firebaseDatabase.checkIfDocExists(
          "student_courses", entryNumber);
      if (!check) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Entry Number ${entryInput.text} is not in the database")));
      }
      return check;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Entry Number ${entryInput.text} is not valid")));
    return false;
  }

  void getStudentsCSV(List<dynamic> fields) async {
    inputFormat = true;
    Set<String> studs = {};
    for (int i = 1; i < fields.length; i++) {
      String entryNumber = fields[i][0].toString().toLowerCase();
      if (await checkEntryNumber(entryNumber)) {
        studs.add(entryNumber);
      } else {
        print(entryNumber);
        inputFormat = false;
      }
    }
    setState(() {
      students = studs;
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

  Widget addSingleStudent() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextFormField(
            controller: entryInput,
            decoration: const InputDecoration(
                icon: Icon(Icons.description),
                labelText: "Enter Entry Number "),
          )),
      IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            if (await checkEntryNumber(entryInput.text.toLowerCase())) {
              setState(
                () {
                  students.add(entryInput.text.toLowerCase());
                  entryInput.clear();
                },
              );
              // FocusScopeNode currentFocus = FocusScope.of(context);
              // if (!currentFocus.hasPrimaryFocus) {
              //   currentFocus.unfocus();
              // }
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
                    const Text('1. Entry number should be valid.')
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
        backgroundColor: Colors.redAccent,
      ),
      child: const Text('Upload via CSV'),
    ));
  }

  Widget selectCourses() {
    List options = courses.toList();
    if (!options.contains("None")) options.add('None');

    return DropdownButtonFormField<String>(
      value: current_course,
      decoration: InputDecoration(
        labelText: 'Choose a Course',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: options.map((dynamic value) {
        return DropdownMenuItem<String>(
          value: value.toString(),
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: (dynamic newValue) async {
        setState(() {
          current_course = newValue;
        });
        if (current_course != 'None') {
          List<dynamic> studentList = await firebaseDatabase.getStudents(current_course!);
          setState(() {
            students = Set.from(studentList);
          });
        } else {
          setState(() {
            students = {};
          });
        }
      },
    );
  }


  Widget getStudents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Students',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 16),

              // Select Course
              Text(
                'Select Course',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              selectCourses(),
              const SizedBox(height: 16),
              Divider(thickness: 1, color: Colors.grey.shade300),

              // Add Student
              const SizedBox(height: 16),
              Text(
                'Add Student (Manually)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              addSingleStudent(),
              const SizedBox(height: 16),
              Divider(thickness: 1, color: Colors.grey.shade300),

              // CSV Upload
              const SizedBox(height: 16),
              Text(
                'Upload Students via CSV',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              getCSVscreen(),

              const SizedBox(height: 8),
              Divider(thickness: 2, color: Colors.indigo.withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }


  Widget showSelectedStudents() {
    final studentList = students.toList(); // Convert Set to List for indexing

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Selected Students',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
          decoration: BoxDecoration(
           // color: theme.of(context).,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: studentList.isEmpty
              ? const Center(
            child: Text(
              'No students selected.',
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: studentList.length,
            itemBuilder: (BuildContext context, int index) {
              final entry = studentList[index];
              final name = entryToName[entry];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey.shade100,
                    child: const Icon(Icons.person, color: Colors.black87),
                  ),
                  title: Text(
                    name == null ? entry : '$entry ($name)',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        students.remove(entry); // This is valid for a Set
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget getSlot() {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.blueGrey;
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor.withOpacity(0.5);
    final iconTheme = theme.iconTheme.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Select Slot Length (in hours)',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cardColor,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                color: Colors.redAccent, // You can also adapt this if desired
                onPressed: () {
                  if (slotLength > 1) {
                    setState(() {
                      slotLength--;
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$slotLength hr',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                color: Colors.green, // Same here, adapt if needed
                onPressed: () {
                  if (slotLength < 12) {
                    setState(() {
                      slotLength++;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }



  Widget getDate() {
    final theme = Theme.of(context); // Get the current theme
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.blueGrey;
    final iconColor = theme.iconTheme.color ?? Colors.blueGrey;
    final borderColor = theme.dividerColor.withOpacity(0.5);
    final backgroundColor = theme.cardColor;

    return Center(
      child: GestureDetector(
        onTap: () async {
          final selected = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (selected != null && selected != date) {
            setState(() {
              date = selected;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, color: iconColor),
              const SizedBox(width: 10),
              Text(
                date == null ? 'Pick Event Date' : formatDateWord(date),
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  List<int> conflicts = List.empty();

  Widget submitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0, top: 16.0),
      child: SizedBox(
        width: 250, // Smaller width
        height: 50, // Smaller height
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary, // More vibrant color
            elevation: 8, // Slightly higher elevation for more emphasis
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Slightly more rounded for a modern feel
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32),
          ),
          onPressed: () async {
            DateTime currentDate = DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day);
            if (date.compareTo(currentDate) < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Previous date events are not allowed"),
                ),
              );
              return;
            }
            if (students.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Add at least one student")),
              );
              return;
            }

            LoadingScreen.setPrompt('Compiling conflicts ...');
            LoadingScreen.setBuilder((context) =>
                seeSlots(slotLength: slotLength, conflicts: conflicts));
            LoadingScreen.setTask(
                    () => getConflicts(slotLength, date, students.toList()));
            Navigator.push(
                context, MaterialPageRoute(builder: LoadingScreen.build));
          },
          child: const Text(
            'Submit',
            style: TextStyle(
              fontSize: 18, // Slightly smaller text for a better proportion
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }



  Future<bool> getConflicts(
      int slotLength, DateTime date, List<String> students) async {
    conflicts = List.filled(12 - 2 * slotLength, 0);

    const weekdays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    changedDay? cd = await firebaseDatabase.getChangedDay(date);
    if (cd != null) {
      for (int i = 0; i < 7; i++) {
        if (cd.day_to_followed == weekdays[i]) {
          int diff = date.weekday - (i + 1);
          date = diff > 0
              ? date.add(Duration(days: diff))
              : date.subtract(Duration(days: -diff));
        }
      }
    }

    // if (Loader.courseToSlot == null) {
    //   await Loader.loadSlots();
    // }
    await Loader.loadSlots();
    // if (Loader.slotToTime == null) {
    //   await Loader.loadTimes();
    // }
    await Loader.loadTimes();

    for (int m = 0; m < students.length; m++) {
      var courses = await firebaseDatabase.getCourses(students[m]);
      for (int i = 0; i < courses.length; i++) {
        courses[i] = courses[i].replaceAll(' ', '');
      }

      for (int i = 0; i < courses.length; i++) {
        for (int j = 0; j < 2; j++) {
          String? slot = Loader.courseToSlot![courses[i]];
          //  Processes as Tutorial or Class
          slot = (j == 0) ? (slot) : ('T-$slot');
          List<String>? times = Loader.slotToTime![slot];
          if (times == null) continue;

          for (int k = 0; k < times.length; k++) {
            var l = times[k].split('|');
            String day = l[0];
            if (day.compareTo(weekdays[date.weekday - 1]) != 0) continue;

            TimeOfDay s = str2tod(l[1]);
            TimeOfDay e = str2tod(l[2]);
            int from = s.hour;
            int to = (e.minute == 0) ? e.hour : e.hour + 1;

            int slotStart = 8;
            int slotEnd = slotStart + slotLength;
            int idx = 0;
            for (; idx < (conflicts.length) / 2; idx++) {
              if (from >= slotStart && from < slotEnd) {
                conflicts[idx]++;
              } else if (to > slotStart && to <= slotEnd) {
                conflicts[idx]++;
              }
              slotStart++;
              slotEnd++;
            }
            slotStart = 14;
            slotEnd = slotStart + slotLength;
            for (; idx < conflicts.length; idx++) {
              if (from >= slotStart && from < slotEnd) {
                conflicts[idx]++;
              } else if (to > slotStart && to <= slotEnd) {
                conflicts[idx]++;
              }
              slotStart++;
              slotEnd++;
            }
          }
        }

        List<ExtraClass> lec = await firebaseDatabase.getExtraClass(courses[i]);

        for (ExtraClass ec in lec) {
          if (ec.date.year == date.year &&
              ec.date.month == date.month &&
              ec.date.day == date.day) {
            TimeOfDay s = ec.startTime;
            TimeOfDay e = ec.endTime;
            int from = s.hour;
            int to = (e.minute == 0) ? e.hour : e.hour + 1;

            int slotStart = 8;
            int slotEnd = slotStart + slotLength;
            int idx = 0;
            for (; idx < (conflicts.length) / 2; idx++) {
              if (from >= slotStart && from < slotEnd) {
                conflicts[idx]++;
              } else if (to > slotStart && to <= slotEnd) {
                conflicts[idx]++;
              }
              slotStart++;
              slotEnd++;
            }
            slotStart = 14;
            slotEnd = slotStart + slotLength;
            for (; idx < conflicts.length; idx++) {
              if (from >= slotStart && from < slotEnd) {
                conflicts[idx]++;
              } else if (to > slotStart && to <= slotEnd) {
                conflicts[idx]++;
              }
              slotStart++;
              slotEnd++;
            }
          }
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Slots"),
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          children: [
            // Add Students Section (Select Course + Add Manually + CSV Upload)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Students',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Course',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    selectCourses(),
                    const SizedBox(height: 16),
                    Divider(thickness: 1, color: theme.dividerColor),
                    const SizedBox(height: 16),
                    Text(
                      'Add Student (Manually)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    addSingleStudent(),
                    const SizedBox(height: 16),
                    Divider(thickness: 1, color: theme.dividerColor),
                    const SizedBox(height: 16),
                    Text(
                      'Upload Students via CSV',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    getCSVscreen(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Selected Students List
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: showSelectedStudents(),
              ),
            ),

            const SizedBox(height: 20),

            // Slot Length and Date Picker in a single card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getSlot(),
                    getDate(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button Centered
            Center(child: submitButton()),
          ],
        ),
      ),
    );
  }

}
