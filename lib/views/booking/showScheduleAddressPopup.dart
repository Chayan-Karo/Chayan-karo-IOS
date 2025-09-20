import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'showReschedulePopup.dart';

Future<String?> showScheduleAddressPopup(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _ScheduleAddressSheet(),
        ),
      );
    },
  );
}

class _ScheduleAddressSheet extends StatefulWidget {
  const _ScheduleAddressSheet({Key? key}) : super(key: key);
  @override
  State<_ScheduleAddressSheet> createState() => _ScheduleAddressSheetState();
}

class _ScheduleAddressSheetState extends State<_ScheduleAddressSheet> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTabletDevice = constraints.maxWidth > 600;
        final double scaleFactor =
            isTabletDevice ? constraints.maxWidth / 411 : 1.0;
        final addressText =
            'Plot no.209, Kavuri Hills, Madhapur, Telangana 500033\nPh: +91234567890';

        Widget content = Container(
          height: 330.h * scaleFactor,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20.h * scaleFactor)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.h * scaleFactor, vertical: 20.h * scaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                Text(
                  'Select address',
                  style: TextStyle(
                    fontSize: 16.sp * scaleFactor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h * scaleFactor),
                /// Add new address (below title)
                GestureDetector(
                  onTap: () {
                    // Add address logic here
                  },
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Color(0xFFFF7900), size: 18 * scaleFactor),
                      SizedBox(width: 4.w * scaleFactor),
                      Text(
                        'Add new address',
                        style: TextStyle(
                          fontSize: 14.sp * scaleFactor,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF7900),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h * scaleFactor),
                Divider(height: 1.h * scaleFactor),
                SizedBox(height: 12.h * scaleFactor),
                /// Address Card
                GestureDetector(
                  onTap: () {
                    setState(() => isSelected = true);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: isSelected,
                        activeColor: Colors.black,
                        onChanged: (_) {
                          setState(() => isSelected = true);
                        },
                      ),
                      SizedBox(width: 4.w * scaleFactor),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/homy.svg',
                                  width: 20.w * scaleFactor,
                                  height: 20.h * scaleFactor,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 6.w * scaleFactor),
                                Text('Home',
                                    style: TextStyle(
                                      fontSize: 14.sp * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    )),
                              ],
                            ),
                            SizedBox(height: 6.h * scaleFactor),
                            Text(
                              'Plot no.209, Kavuri Hills, Madhapur, Telangana 500033',
                              style: TextStyle(
                                fontSize: 13.sp * scaleFactor,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.h * scaleFactor),
                            Text('Ph: +91234567890',
                                style: TextStyle(
                                  fontSize: 13.sp * scaleFactor,
                                  color: Colors.black,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                /// Proceed Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h * scaleFactor,
                  child: ElevatedButton(
                    onPressed: isSelected
                        ? () {
                            Navigator.pop(context,
                                addressText); // Return the selected address string on pop
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? const Color(0xFFFF7900) : const Color(0xFFE0E0E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scaleFactor),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Proceed',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return content;
      },
    );
  }
}
