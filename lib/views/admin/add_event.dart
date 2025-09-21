import 'package:flutter/material.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Color(secondaryLight),
          automaticallyImplyLeading: false,
          title: buildTitleBar("ADD EVENT", context),
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
  late String eventTitle = "";
  late String eventType = "";
  late String eventDesc = "";
  late DateTime eventDate;
  late String eventVenue = "";
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  String? imageURL;
  XFile? file;

  AddEventFormState() {
    eventDate = DateTime.now();
    startTime = TimeOfDay.now();
    endTime = TimeOfDay.now();
  }
  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;
  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  Widget _buildEventTitle() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Event Title'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Event Title is required';
        }
        return null;
      },
      onSaved: (String? value) {
        eventTitle = value!;
      },
    );
  }

  Widget _buildEventType() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Event Type'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Event Type is required';
        }
        return null;
      },
      onSaved: (String? value) {
        eventType = value!;
      },
    );
  }

  Widget _buildEventDesc() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Event Description'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Event Description is required';
        }
        return null;
      },
      onSaved: (String? value) {
        eventDesc = value!;
      },
    );
  }

  Widget _buildEventVenue() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Event Venue'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Event Venue is required';
        }
        return null;
      },
      onSaved: (String? value) {
        eventVenue = value!;
      },
    );
  }

  Widget _buildEventDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateColor.resolveWith((states) => Color(primaryLight)),
          ),
            child: const SizedBox(
              width: 120,
              child: Text(
              'Pick Event Date',
              style: TextStyle(color: Colors.white),
              ),
            ),
          onPressed: () {
            showDatePicker(
                    context: context,
                    initialDate: eventDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100))
                .then((date) {
              if (date != null && date != eventDate) {
                setState(() {
                  eventDate = date;
                });
              }
            });
          },
        ),
        Text("${eventDate.day}/${eventDate.month}/${eventDate.year}",
            style: const TextStyle(fontSize: 24)),
      ],
    );
  }

  Widget _buildStartTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateColor.resolveWith((states) => Color(primaryLight)),
          ),
          child: const SizedBox(
              width: 120,
              child: Text(
              'Set Start Time',
              style: TextStyle(color: Colors.white),
              ),
          ),
          onPressed: () {
            showTimePicker(
              context: context,
              initialTime: startTime,
            ).then((time) {
              if (time != null && time != startTime) {
                setState(() {
                  startTime = time;
                });
              }
            });
          },
        ),
        const SizedBox(width: 20),
        Text(tod2str(startTime), style: const TextStyle(fontSize: 24)),
      ],
    );
  }

  Widget _buildEndTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateColor.resolveWith((states) => Color(primaryLight)),
          ),
          child: const SizedBox(
            width: 120,
            child: Text(
              'Set End Time',
              style: TextStyle(color: Colors.white),
            ),
          ),
          onPressed: () {
            showTimePicker(
              context: context,
              initialTime: endTime,
            ).then((time) {
              if (time != null && time != endTime) {
                setState(() {
                  endTime = time;
                });
              }
            });
          },
        ),
        const SizedBox(width: 20),
        Text(tod2str(endTime), style: const TextStyle(fontSize: 24)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventTitle(),
              _buildEventType(),
              _buildEventDesc(),
              _buildEventVenue(),
              const SizedBox(height: 20),
              _buildEventDate(),
              _buildStartTime(),
              _buildEndTime(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Add Event Image',
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();

                      // Pick an image
                      XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                      if (file != null) {
                        print("${file.path} added!");

                        String filename = DateTime.now().millisecondsSinceEpoch.toString();
                        Reference refDir = FirebaseStorage.instance.ref().child('images');
                        Reference imgToUpload = refDir.child(filename);
                        String filePath = file.path;

                        try {
                          // Show "Uploading" snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Uploading image..."), duration: Duration(seconds: 2)),
                          );

                          // Upload file
                          await imgToUpload.putFile(File(filePath));

                          // Retrieve download URL
                          imageURL = await imgToUpload.getDownloadURL();
                          print("Image URL: $imageURL");

                          // Show success snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Image Added Successfully")),
                          );

                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error adding image")),
                          );
                          print("Upload error: $error");
                        }
                      } else {
                        print("No file selected!");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No image selected")),
                        );
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                  ),

                  // IconButton(
                  //     onPressed: () async {
                  //       ImagePicker imagepicker =
                  //           ImagePicker(); // pick an image
                  //       file = await imagepicker.pickImage(
                  //           source: ImageSource.gallery);
                  //     },
                  //     icon: const Icon(Icons.camera_alt)),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Color(primaryLight)),
                    ),
                    onPressed: () async {
                      // Validate date and time conditions first
                      if (eventDate.compareTo(getTodayDateTime()) <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Previous date events are not allowed")),
                        );
                        return;
                      }
                      if (toDouble(startTime) > toDouble(endTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Invalid Time. End time is before start time.")),
                        );
                        return;
                      }
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // If a file is selected, upload it and get the URL.
                        print("imageURL_here:");
                        print(imageURL);

                        // Show confirmation dialog AFTER ensuring imageURL is set.
                        showDialog(

                          context: context,
                          builder: (BuildContext context) {

                            return AlertDialog(
                              title: const Text('Confirmation'),
                              content: Text(
                                  "Are you sure you want to add event $eventTitle ?"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog.
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('Submit'),
                                  onPressed: () {
                                    // Use the (now hopefully non-null) imageURL here.
                                    firebaseDatabase.addEventFB(
                                      eventTitle,
                                      eventType,
                                      eventDesc,
                                      eventVenue,
                                      "${eventDate.day}/${eventDate.month}/${eventDate.year}",
                                      tod2str(startTime),
                                      tod2str(endTime),
                                      imageURL,
                                      "admin",
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Event Added Successfully")),
                                    );
                                    Navigator.of(context).pop(); // Close the dialog.
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const SizedBox(
                      width: 120,
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),


                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
