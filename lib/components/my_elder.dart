import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class MyElder extends StatelessWidget {
  final String elderName;
  final elderProfile;
  const MyElder(
      {super.key, required this.elderName, required this.elderProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 97,
      height: 128,
      margin: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(
          color: Color(0xfff8f8f8),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // profile
          Container(
            width: 71,
            height: 71,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: NetworkImage(elderProfile), fit: BoxFit.cover)),
          ),

          // name
          SizedBox(
              width: 120,
              height: 30,
              child: Text(elderName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sen(
                      fontSize: 16, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }
}
