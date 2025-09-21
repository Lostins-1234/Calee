import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitropar/utilities/firebase_database.dart';

class StudentsList extends StatefulWidget {
  final String course;
  const StudentsList({super.key, required this.course});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  List<List<dynamic>> studentList = [];
  Set<String> selectedRolls = {};
  final TextEditingController _groupNameController = TextEditingController();
  bool selectAll = false;
  List<String> groupList = [];

  @override
  void initState() {
    super.initState();
    _getStudents();
    _loadGroupsForCourse(widget.course);
  }

  void _getStudents() async {
    List<List<dynamic>> students = await firebaseDatabase.getStudentsWithName(widget.course);
    setState(() {
      studentList = students;
      if (selectAll) {
        selectedRolls = studentList.map((e) => e[0].toString()).toSet();
      }
    });
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
        });
      }
    } else {
      setState(() {
        groupList = [];
      });
    }
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      selectedRolls = value
          ? studentList.map((e) => e[0].toString()).toSet()
          : <String>{};
    });
  }

  void _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty || selectedRolls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a group name and select students")),
      );
      return;
    }

    for (var student in selectedRolls) {
      await firebaseDatabase.addGroupToStudentCourse(
        roll: student,
        courseCode: widget.course,
        groupName: groupName,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Group '$groupName' created successfully")),
    );

    setState(() {
      selectedRolls.clear();
      _groupNameController.clear();
      selectAll = false;
    });

    _loadGroupsForCourse(widget.course); // Refresh the group list
  }

  void _showStudentsInGroup(String groupName) async {
    final labInfoDoc = await FirebaseFirestore.instance
        .collection('coursecode')
        .doc(widget.course)
        .collection(groupName)
        .doc('lab_info')
        .get();

    if (labInfoDoc.exists) {
      final data = labInfoDoc.data();
      final List<dynamic> rolls = data?['students'] ?? [];

      final studentsInGroup = studentList
          .where((student) => rolls.contains(student[0]))
          .map((student) => "${student[1]} (${student[0]})")
          .toList();

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Students in $groupName",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                if (studentsInGroup.isEmpty)
                  const Text("No students in this group."),
                ...studentsInGroup.map((s) => ListTile(title: Text(s))).toList(),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Students to Group")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: "Enter Group Name",
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 12),

            // Existing Groups Section
            if (groupList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.groups, size: 20),
                      SizedBox(width: 6),
                      Text(
                        "Existing Groups",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: groupList.map((group) {
                      return InkWell(
                        onTap: () => _showStudentsInGroup(group),
                        child: Chip(
                          label: Text(group),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Select All Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select All Students",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: selectAll,
                  onChanged: _toggleSelectAll,
                ),
              ],
            ),

            const Divider(),

            // Student List
            Expanded(
              child: ListView.builder(
                itemCount: studentList.length,
                itemBuilder: (context, index) {
                  final roll = studentList[index][0];
                  final name = studentList[index][1];
                  final isSelected = selectedRolls.contains(roll);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1,
                    child: ListTile(
                      title: Text("$name ($roll)"),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedRolls.add(roll);
                            } else {
                              selectedRolls.remove(roll);
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Create Group Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createGroup,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Create Group"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(fontSize: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
