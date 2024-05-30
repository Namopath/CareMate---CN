import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyPill extends StatelessWidget {
  final String pillName;
  final String time;
  final String timeIndicator;
  const MyPill(
      {super.key,
      required this.pillName,
      required this.time,
      required this.timeIndicator});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2.5, top: 2.5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: ColorAsset.secondary, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // pill name
          SizedBox(
            width: 120,
            height: 30,
            child: Center(
              child: Text(pillName,
                  style: GoogleFonts.sen(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),

          SizedBox(
            width: 6,
            height: 30,
            child: Center(
              child: Text(";",
                  style: GoogleFonts.sen(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),

          // time
          SizedBox(
            width: 114,
            height: 30,
            child: Center(
              child: Text(time,
                  style: GoogleFonts.sen(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),

          // time indicator
          SizedBox(
            width: 50,
            height: 30,
            child: Center(
              child: Text(timeIndicator,
                  style: GoogleFonts.sen(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
