import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/faculty/findSlot.dart';
import 'package:iitropar/frequently_used.dart';
//import 'package:iitropar/firebase_database.dart';
import 'package:iitropar/views/faculty/scheduleCourse.dart';
import 'package:iitropar/views/faculty/showClasses.dart';
import '../../utilities/colors.dart';
import 'home_page.dart';
import 'package:iitropar/views/faculty/studentsEnrolled.dart';
import 'package:iitropar/views/faculty/create_group_screen.dart';
import 'package:iitropar/views/faculty/createLabs.dart';


class FacultyHome extends AbstractHome {
  const FacultyHome({Key? key})
      : super(
    key: key,
    appBarBackgroundColor: const Color(0xFFAD1457),
  );

  @override
  State<AbstractHome> createState() => _FacultyHomeState();
}

class _FacultyHomeState extends AbstractHomeState {
  semesterDur? sm;
  List<Color> colors = [
    const Color(0xFF566e7a),
    const Color(0xFF161a26),
    const Color(0xFF599d70),
    const Color(0xFF3367d5),
    const Color(0xFFf9a61a)
  ];
  void getSemesterDur() async {
    sm = await firebaseDatabase.getSemDur();
    if (mounted) setState(() {});
  }

  Widget allCourses() {
    getSemesterDur();
    List<dynamic> coursesList = f.courses.toList();
    if (coursesList.isEmpty) {
      return const Text('Contact Admin for addition of courses');
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xff555555),
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            blurStyle: BlurStyle.outer,
            color: Color(primaryLight),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Your Courses",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: 150,
              child: ListView.builder(
                // shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: coursesList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (coursesList[index] == "None") return Container();
                  final colorIndex = index % colors.length;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              studentsEnrolled(course: coursesList[index]),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        //color: Colors.black,
                        color: colors[colorIndex],
                      ),
                      child: ListTile(
                        title: Text(
                          coursesList[index],
                          style: TextStyle(color: Color(secondaryLight)),
                          //style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Text(
            "To add new course, contact Admin",
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  @override
  List<Widget> buttons() {
    List<Widget> l = [];

    l.add(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Semester Start Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            Text('${sm == null ? '' : formatDateWord(sm!.startDate!)}'),
            const SizedBox(height: 8.0),
            Text('Semester End Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            Text('${sm == null ? '' : formatDateWord(sm!.endDate!)}'),
          ],
        ),
      ),
    );

    l.add(allCourses());
    l.add(const SizedBox(height: 16));

    l.add(
      Column(
        children: [
          // First Row: 2 wide buttons
          Row(
            children: [
              Expanded(
                child: _buildStyledActionCard(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Check Free Slots',
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => findSlots(f.courses)));
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStyledActionCard(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Create Extra Class',
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CourseSchedule(courses: f.courses)));
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12), // Increased spacing between rows

          // Second Row: 3 tighter buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStyledActionCard(
                context,
                icon: Icons.list,
                label: 'See Extra Classes',
                compact: true,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyClass(courses: f.courses)));
                },
              ),
              _buildStyledActionCard(
                context,
                icon: Icons.group_add,
                label: 'Create Group',
                compact: true,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CreateGroupScreen()));
                },
              ),
              _buildStyledActionCard(
                context,
                icon: Icons.science,
                label: 'Manage Labs',
                compact: true,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => createLabs()));
                },
              ),
            ],
          ),
        ],
      ),
    );


    return l;
  }

  Widget _buildStyledActionCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        bool compact = false, // Set true for 3-button row
      }) {
    return SizedBox(
      width: compact ? MediaQuery.of(context).size.width / 3.5 : double.infinity,
      height: 90,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.grey.withOpacity(0.3),
        margin: const EdgeInsets.all(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: Colors.grey),
                SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
