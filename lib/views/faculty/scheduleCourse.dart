import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/firebase_database.dart';

class CourseSchedule extends StatefulWidget {
  final Set<dynamic> courses;
  TimeOfDay st = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay et = const TimeOfDay(hour: 9, minute: 0);
  CourseSchedule({required this.courses, st, et});

  @override
  _CourseScheduleState createState() => _CourseScheduleState();
}

class _CourseScheduleState extends State<CourseSchedule> {
  late String selectedCourse;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late String venue;
  late String description;
  late DateTime date;
  late Set<dynamic> allcourses = Set<dynamic>();
  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    allcourses = widget.courses;
    allcourses.add("None");
    selectedCourse = widget.courses.first;
    startTime = widget.st;
    endTime = widget.et;
    venue = '';
    description = '';
  }

  Future<void> _showStartTimePicker() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: startTime,
    );

    if (newTime != null) {
      setState(() {
        startTime = newTime;
      });
    }
  }

  Future<void> _showEndTimePicker() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: endTime,
    );

    if (newTime != null) {
      setState(() {
        endTime = newTime;
      });
    }
  }

  void _onVenueChanged(String newValue) {
    setState(() {
      venue = newValue;
    });
  }

  void _onDescriptionChanged(String newValue) {
    setState(() {
      description = newValue;
    });
  }

  Widget selectCourse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            'Select Course',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: selectedCourse,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: Theme.of(context).colorScheme.surface,
          items: allcourses.toList().map((dynamic course) {
            return DropdownMenuItem<String>(
              value: course,
              child: Text(course, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedCourse = newValue!;
            });
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }


  Widget selectTime() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('Start Time'),
            trailing: Text('${startTime.format(context)}'),
            onTap: _showStartTimePicker,
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('End Time'),
            trailing: Text('${endTime.format(context)}'),
            onTap: _showEndTimePicker,
          ),
        ),
      ],
    );
  }

  Widget selectVenue() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Venue',
        hintText: 'Enter the venue',
      ),
      onChanged: _onVenueChanged,
    );
  }

  Widget selectDescription() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Enter the description',
      ),
      onChanged: _onDescriptionChanged,
    );
  }

  Widget selectDate() {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.blueGrey;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          child: Center(
            child: Text("Date: ${date.day}/${date.month}/${date.year}",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: textColor,)),
          ),
          onPressed: () {
            showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100))
                .then((_date) {
              if (_date != null && _date != date) {
                setState(() {
                  date = _date;
                });
              }
            });
          },
        ),
      ],
    );
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  Widget sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget cardContainer(Widget child) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: child,
      ),
    );
  }

  Widget customDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(
        color: Colors.grey,
        thickness: 0.5,
      ),
    );
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Schedule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            customDivider(),
            sectionHeader(Icons.book, "Select Course"),
            cardContainer(selectCourse()),

            customDivider(),
            sectionHeader(Icons.calendar_today, "Pick Date"),
            cardContainer(selectDate()),

            const SizedBox(height: 8),
            sectionHeader(Icons.access_time, "Select Time"),
            cardContainer(selectTime()),

            customDivider(),
            sectionHeader(Icons.place, "Venue"),
            cardContainer(selectVenue()),

            customDivider(),
            sectionHeader(Icons.description, "Description"),
            cardContainer(selectDescription()),

            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAD1457),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
                onPressed: () async {
                  if (selectedCourse == "None") {
                    showSnack("Please select a course!");
                    return;
                  }
                  if (description.isEmpty) {
                    showSnack("Add description.");
                    return;
                  }
                  if (venue.isEmpty) {
                    showSnack("Add venue");
                    return;
                  }
                  if (date.compareTo(getTodayDateTime()) <= 0) {
                    showSnack("Previous date events are not allowed");
                    return;
                  }
                  if (toDouble(startTime) > toDouble(endTime)) {
                    showSnack("Invalid Time. End time is before start time.");
                    return;
                  }

                  ExtraClass c = ExtraClass(
                    courseID: selectedCourse,
                    date: date,
                    startTime: startTime,
                    endTime: endTime,
                    description: description,
                    venue: venue,
                  );

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: Text(
                          "Do you really want to schedule a class on ${formatDateWord(c.date)}?",
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text("Add"),
                            onPressed: () async {
                              bool hasSubmit = await firebaseDatabase.addExtraClass(c);
                              if (hasSubmit) {
                                showSnack("Event added successfully!");
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}
