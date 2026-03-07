import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shows a bottom sheet asking to discard changes.
/// Returns [true] if user wants to Discard (Exit).
/// Returns [false] (or null) if user wants to Keep Editing (Stay).
Future<bool> showDiscardChangesSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final scale = MediaQuery.of(context).size.width >= 600 
          ? MediaQuery.of(context).size.width / 411 
          : 1.0;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w * scale, vertical: 24.h * scale),
        // REMOVED INCORRECT LINE: mainAxisSize: MainAxisSize.min, 
        child: Column(
          mainAxisSize: MainAxisSize.min, // This remains correct for the Column
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w * scale,
                height: 4.h * scale,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
              ),
            ),
            SizedBox(height: 20.h * scale),
            
            // Title
            Text(
              "Discard changes?",
              style: TextStyle(
                fontSize: 18.sp * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h * scale),
            
            // Subtitle
            Text(
              "If you go back now, your changes will be discarded.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp * scale,
                color: const Color(0xFF757575),
              ),
            ),
            SizedBox(height: 24.h * scale),
            
            // Buttons Row
            Row(
              children: [
                // Keep Editing Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h * scale),
                      side: BorderSide(color: const Color(0xFFE47830), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8 * scale)),
                    ),
                    child: Text(
                      "Keep Editing",
                      style: TextStyle(
                        color: const Color(0xFFE47830),
                        fontSize: 15.sp * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w * scale),
                
                // Discard Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE47830),
                      padding: EdgeInsets.symmetric(vertical: 12.h * scale),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8 * scale)),
                      elevation: 0,
                    ),
                    child: Text(
                      "Discard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h * scale), // Safe area buffer
          ],
        ),
      );
    },
  );

  return result ?? false;
}