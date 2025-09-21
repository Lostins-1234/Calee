import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/utilities/firebase_database.dart';

class createLabs extends StatefulWidget {
  const createLabs({super.key});

  @override
  State<createLabs> createState() => _createLabsState();
}

class _createLabsState extends State<createLabs> {
  List<String> courseList = [];
  List<String> groupList = [];
  List<Map<String, dynamic>> scheduledLabs = [];

  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  String? selectedCourse;
  String? selectedGroup;
  String? selectedDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController venueController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacultyCourses();
  }

  Future<void> _loadFacultyCourses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final faculty = await firebaseDatabase.getFacultyDetail(user.email!);
      setState(() {
        courseList = (faculty?.courses.where((c) => c != "None").toList() ?? []).cast<String>();
        isLoading = false;
      });
    }
  }

  Future<void> _loadGroupsForCourse(String courseCode) async {
    final doc = await FirebaseFirestore.instance
        .collection('coursecode')
        .doc(courseCode)
        .collection('meta')
        .doc('groups')
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('groups')) {
        setState(() {
          groupList = List<String>.from(data['groups']);
          selectedGroup = null;
          scheduledLabs = [];
        });
      }
    } else {
      setState(() {
        groupList = [];
        selectedGroup = null;
        scheduledLabs = [];
      });
    }
  }

  Future<void> _loadScheduledLabs() async {
    if (selectedCourse == null || selectedGroup == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('coursecode')
        .doc(selectedCourse)
        .collection(selectedGroup!)
        .doc('lab_info')
        .get();

    if (doc.exists && doc.data() != null) {
      setState(() {
        scheduledLabs = [doc.data()!..['id'] = doc.id];
      });
    } else {
      setState(() {
        scheduledLabs = [];
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _submitLab() async {
    if (selectedCourse == null ||
        selectedGroup == null ||
        selectedDay == null ||
        startTime == null ||
        endTime == null ||
        venueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final labRef = FirebaseFirestore.instance
        .collection('coursecode')
        .doc(selectedCourse)
        .collection(selectedGroup!)
        .doc('lab_info');

    await labRef.set({
      'day': selectedDay,
      'start_time': startTime!.format(context),
      'end_time': endTime!.format(context),
      'venue': venueController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lab scheduled successfully")),
    );

    setState(() {
      selectedDay = null;
      startTime = null;
      endTime = null;
      venueController.clear();
    });

    _loadScheduledLabs();
  }

  Future<void> _deleteLab() async {
    if (selectedCourse == null || selectedGroup == null) return;

    final labRef = FirebaseFirestore.instance
        .collection('coursecode')
        .doc(selectedCourse)
        .collection(selectedGroup!)
        .doc('lab_info');

    await labRef.set({
      'day': null,
      'start_time': null,
      'end_time': null,
      'venue': null,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lab reset successfully")),
    );

    _loadScheduledLabs();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Lab")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create New Lab",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: "Select Course"),
                                value: selectedCourse,
                                isExpanded: true,
                                items: courseList.map((course) {
                                  return DropdownMenuItem(
                                    value: course,
                                    child: Text(course),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCourse = value;
                                    selectedGroup = null;
                                    groupList = [];
                                    scheduledLabs = [];
                                  });
                                  _loadGroupsForCourse(value!);
                                },
                              ),
                              const SizedBox(height: 10),

                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: "Select Group"),
                                value: selectedGroup,
                                isExpanded: true,
                                items: groupList.map((group) {
                                  return DropdownMenuItem(
                                    value: group,
                                    child: Text(group),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGroup = value;
                                    scheduledLabs = [];
                                  });
                                  _loadScheduledLabs();
                                },
                              ),
                              const SizedBox(height: 10),

                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: "Select Day"),
                                value: selectedDay,
                                isExpanded: true,
                                items: days.map((day) {
                                  return DropdownMenuItem(
                                    value: day,
                                    child: Text(day),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDay = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.access_time, size: 18),
                                      label: Text(
                                        startTime != null
                                            ? "Start: ${startTime!.format(context)}"
                                            : "Start Time",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      onPressed: () => _pickTime(true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 150,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.access_time, size: 18),
                                      label: Text(
                                        endTime != null
                                            ? "End: ${endTime!.format(context)}"
                                            : "End Time",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      onPressed: () => _pickTime(false),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              TextField(
                                controller: venueController,
                                decoration: const InputDecoration(
                                  labelText: "Enter Venue",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),

                              ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                onPressed: _submitLab,
                                label: const Text("Submit Lab"),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(45),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        "Scheduled Lab",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      if (scheduledLabs.isEmpty)
                        const Text(
                          "No lab scheduled for the selected group.",
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...scheduledLabs.map((lab) {
                          if (lab['day'] == null &&
                              lab['start_time'] == null &&
                              lab['end_time'] == null &&
                              lab['venue'] == null) {
                            return const Text(
                              "No lab scheduled for the selected group.",
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: const Icon(Icons.schedule),
                              title: Text(
                                "${lab['day']} • ${lab['start_time']} - ${lab['end_time']}",
                              ),
                              subtitle: Text("Venue: ${lab['venue']}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: "Reset Lab Info",
                                onPressed: _deleteLab,
                              ),
                            ),
                          );
                        }),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
