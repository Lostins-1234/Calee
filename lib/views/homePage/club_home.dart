import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/views/club/add_club_event.dart';
import 'package:iitropar/views/club/add_group.dart';
import 'package:iitropar/views/club/club_notifications.dart';
import 'package:iitropar/views/club/manage_groups.dart';
import 'package:iitropar/views/club/manage_members.dart';
import '../../frequently_used.dart';
import '../../utilities/colors.dart';
import '../club/manage_events.dart';
import 'home_page.dart';

class ClubHome extends AbstractHome {
  const ClubHome({Key? key})
      : super(
    key: key,
    appBarBackgroundColor: const Color(0xFF32A83C),
  );

  @override
  State<AbstractHome> createState() => _ClubHomeState();
}

class _ClubHomeState extends AbstractHomeState {
  String clubName = "";

  _ClubHomeState() {
    firebaseDatabase
        .getClubName(FirebaseAuth.instance.currentUser!.email!)
        .then((value) {
      setState(() {
        clubName = value;
      });
    });
  }

  Widget ClubAdminCard(BuildContext context, Widget route, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => route));
        },
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    l.add(SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClubAdminCard(context, addClubEvent(clubName: clubName), "Add Event", Icons.event),
              ClubAdminCard(context, ManageEvents(clubName: clubName), "Manage Events", Icons.edit_calendar),
            ],
          ),
          Row(
            children: [
              ClubAdminCard(context, addClubGroup(clubName: clubName), "Create Group", Icons.group_add),
              ClubAdminCard(context, ManageGroupsScreen(clubName: clubName), "Manage Groups", Icons.groups),
            ],
          ),
          Row(
            children: [
              ClubAdminCard(context, ManageMembersScreen(clubName: clubName), "Group Members", Icons.manage_accounts),
              ClubAdminCard(context, ClubNotifications(clubName: clubName), "Notifications", Icons.notifications),
            ],
          ),

        ],
      ),
    ));

    return l;
  }
}