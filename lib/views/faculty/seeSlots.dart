import 'package:flutter/material.dart';

class ConflictSlot {
  TimeOfDay start;
  TimeOfDay end;
  int conflicts;

  ConflictSlot(this.start, this.end, this.conflicts);
}

class seeSlots extends StatefulWidget {
  const seeSlots({
    super.key,
    required this.slotLength,
    required this.conflicts,
  });

  final int slotLength;
  final List<int> conflicts;

  @override
  State<seeSlots> createState() =>
      _seeSlotsState(slotLength: slotLength, conflicts: conflicts);
}

class GradientColorGenerator {
  static Color getColorFromGradient(int value) {
    // Assuming max conflicts = 12
    final int max = 12;
    final double percentage = (value / max).clamp(0.0, 1.0);

    // Green (good) -> Red (bad)
    final int red = (percentage * 255).floor();
    final int green = ((1 - percentage) * 180).floor(); // slightly dimmed green

    return Color.fromRGBO(red, green, 0, 1);
  }
}


class _seeSlotsState extends State<seeSlots> {
  _seeSlotsState({required this.slotLength, required this.conflicts});

  final int slotLength;
  final List<int> conflicts;

  Widget createSlotCard(String startT, String endT, int conflict, BuildContext context) {
    final Color conflictColor = GradientColorGenerator.getColorFromGradient(conflict);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.grey[900] : Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _slotDetail(title: "Start Time", value: startT, context: context),
            _slotDetail(title: "End Time", value: endT, context: context),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conflicts',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: conflictColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    conflict.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotDetail({required String title, required String value, required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget viewSlots(BuildContext context) {
    TimeOfDay slotStart = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay slotEnd = TimeOfDay(hour: 8 + slotLength, minute: 0);
    int totalSlots = 12 - 2 * slotLength;

    List<ConflictSlot> conflictSlots = List.generate(totalSlots, (i) {
      final slot = ConflictSlot(slotStart, slotEnd, conflicts[i]);
      slotStart = TimeOfDay(hour: slotStart.hour + 1, minute: 0);
      slotEnd = TimeOfDay(hour: slotEnd.hour + 1, minute: 0);
      if (slotStart.hour <= 13 && slotEnd.hour > 13) {
        slotStart = const TimeOfDay(hour: 14, minute: 0);
        slotEnd = TimeOfDay(hour: 14 + slotLength, minute: 0);
      }
      return slot;
    });

    conflictSlots.sort((a, b) => a.conflicts.compareTo(b.conflicts));

    return ListView.builder(
      itemCount: conflictSlots.length,
      itemBuilder: (context, index) {
        final slot = conflictSlots[index];
        final start = "${slot.start.hour.toString().padLeft(2, "0")}:${slot.start.minute.toString().padLeft(2, "0")}";
        final end = "${slot.end.hour.toString().padLeft(2, "0")}:${slot.end.minute.toString().padLeft(2, "0")}";
        return createSlotCard(start, end, slot.conflicts, context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Slot Length = $slotLength"),
      ),
      body: viewSlots(context),
    );
  }
}
