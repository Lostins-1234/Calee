// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names

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

class studentsEnrolled extends StatefulWidget {
  final String course;
  const studentsEnrolled({super.key, required this.course});

  @override
  State<studentsEnrolled> createState() => _studentsEnrolledState();
}

class _studentsEnrolledState extends State<studentsEnrolled> {
  late List<List<dynamic>> studentList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getStudents();
  }

  void _getStudents() async {
    List<List<dynamic>> students =
    await firebaseDatabase.getStudentsWithName(widget.course);
    setState(() {
      studentList = students;
      isLoading = false;
    });
  }

  String formatRoll(String roll) {
    final regExp = RegExp(r'(\d*)([a-zA-Z]+)(\d*)');
    final match = regExp.firstMatch(roll);

    if (match != null) {
      final part1 = match.group(1) ?? '';
      final part2 = (match.group(2) ?? '').toUpperCase();
      final part3 = match.group(3) ?? '';
      return '$part1$part2$part3';
    }

    return roll;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students Enrolled"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentList.isEmpty
          ? const Center(child: Text("No students enrolled yet."))
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface, // Theme-based background
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black54
                        : Colors.black12,
                    blurRadius: 12,
                    spreadRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DataTable(
                columnSpacing: 48,
                dataRowHeight: 60,
                headingRowHeight: 64,
                horizontalMargin: 24,
                headingRowColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return states.contains(MaterialState.selected)
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : null;
                  },
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      "Roll No.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
                rows: List.generate(studentList.length, (index) {
                  final student = studentList[index];
                  final roll = formatRoll(student[0].toString());
                  final name = student[1].toString();
                  final isEven = index % 2 == 0;

                  final isDark = Theme.of(context).brightness == Brightness.dark;

                  final rowColor = isEven
                      ? (isDark ? Colors.grey[800] : Colors.grey[100])
                      : (isDark ? Colors.grey[850] : Colors.grey[200]);

                  return DataRow(
                    color: MaterialStateProperty.all(rowColor),
                    cells: [
                      DataCell(
                        Text(
                          roll,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
