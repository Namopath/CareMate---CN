import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final String text;
  const MyButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      child: Center(
        child: Text(text,
            style: GoogleFonts.sen(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorAsset.primary)),
      ),
    );
  }
}
