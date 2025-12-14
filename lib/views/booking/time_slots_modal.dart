import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart'; // Required for Snackbar

/// UPDATED: Added [minTimeConstraint] parameter
Future<TimeOfDay?> showTimeSlotsModal(
  BuildContext context, {
  required DateTime selectedDate,
  String? minTimeConstraint, // <--- 1. Receive the constraint string here
  EdgeInsetsGeometry? padding,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _TimeSlotsSheet(
      selectedDate: selectedDate,
      minTimeConstraint: minTimeConstraint, // <--- 2. Pass it to the widget
      padding: padding,
    ),
  );
}

class _TimeSlotsSheet extends StatefulWidget {
  const _TimeSlotsSheet({
    required this.selectedDate,
    this.minTimeConstraint, // <--- 3. Define variable
    this.padding,
  });

  final DateTime selectedDate;
  final String? minTimeConstraint;
  final EdgeInsetsGeometry? padding;

  @override
  State<_TimeSlotsSheet> createState() => _TimeSlotsSheetState();
}

class _TimeSlotsSheetState extends State<_TimeSlotsSheet> {
  late final List<TimeOfDay> _allSlots;
  late final List<TimeOfDay> _visibleSlots;

  @override
  void initState() {
    super.initState();
    _allSlots = _generateSlots(
      start: const TimeOfDay(hour: 8, minute: 30),   // 8:30 AM
      end: const TimeOfDay(hour: 19, minute: 00),    // 7:00 PM
      stepMinutes: 30,
    );
    _visibleSlots = _filterPastIfToday(_allSlots, widget.selectedDate);
  }

  List<TimeOfDay> _generateSlots({
    required TimeOfDay start,
    required TimeOfDay end,
    required int stepMinutes,
  }) {
    final List<TimeOfDay> list = [];
    TimeOfDay cur = start;

    int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
    TimeOfDay addMinutes(TimeOfDay t, int m) {
      final total = t.hour * 60 + t.minute + m;
      return TimeOfDay(hour: total ~/ 60, minute: total % 60);
    }

    while (toMinutes(cur) <= toMinutes(end)) {
      list.add(cur);
      cur = addMinutes(cur, stepMinutes);
    }
    return list;
  }

  List<TimeOfDay> _filterPastIfToday(List<TimeOfDay> slots, DateTime selected) {
    final now = DateTime.now();
    final isToday = DateTime(now.year, now.month, now.day) ==
        DateTime(selected.year, selected.month, selected.day);

    if (!isToday) return slots;

    final currentMinutes = now.hour * 60 + now.minute;
    return slots.where((t) {
      final m = t.hour * 60 + t.minute;
      return m > currentMinutes; 
    }).toList();
  }

  String _fmt(TimeOfDay t) {
    final dt = DateTime(0, 1, 1, t.hour, t.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  // --- 4. NEW VALIDATION LOGIC ---
  void _onSlotTap(TimeOfDay selectedSlot) {
    // A. Check if there is a constraint
    if (widget.minTimeConstraint == null || widget.minTimeConstraint!.isEmpty) {
      Navigator.pop(context, selectedSlot);
      return;
    }

    // B. Check if the booking is for TODAY
    // (Next Available Time logic usually applies only to the current day)
    final now = DateTime.now();
    final isToday = widget.selectedDate.year == now.year &&
        widget.selectedDate.month == now.month &&
        widget.selectedDate.day == now.day;

    if (isToday) {
      try {
        // Parse "HH:mm:ss" or "HH:mm" from string
        final parts = widget.minTimeConstraint!.split(':');
        final int constraintHour = int.parse(parts[0]);
        final int constraintMinute = int.parse(parts[1]);

        final int constraintTotalMinutes = (constraintHour * 60) + constraintMinute;
        final int selectedTotalMinutes = (selectedSlot.hour * 60) + selectedSlot.minute;

        // C. If Selected Time < Constraint Time -> Show Error
        if (selectedTotalMinutes < constraintTotalMinutes) {
          Get.snackbar(
            'Slot Unavailable',
            'Provider is only available after ${_formatTimeString(widget.minTimeConstraint!)} today.',
            snackPosition: SnackPosition.TOP, // <--- Requested Position
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.error_outline, color: Colors.white),
          );
          return; // STOP execution, do not select
        }
      } catch (e) {
        debugPrint("Error parsing constraint time: $e");
      }
    }

    // D. If valid, proceed
    Navigator.pop(context, selectedSlot);
  }

  // Helper to make "13:30:00" look like "01:30 PM" for the error message
  String _formatTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      final dt = DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16);

    return SafeArea(
      top: false,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select start time of service',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Slots available from 8:30 AM to 7:00 PM',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: _visibleSlots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.7,
                ),
                itemBuilder: (context, i) {
                  final t = _visibleSlots[i];
                  return _SlotChip(
                    label: _fmt(t),
                    onTap: () => _onSlotTap(t), // <--- 5. Call validation here
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

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}