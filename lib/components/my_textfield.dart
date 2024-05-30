import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.prefixIcon,
      required this.obscureText,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      controller: controller,
      cursorColor: ColorAsset.primary,
      style: GoogleFonts.sen(fontWeight: FontWeight.w600, fontSize: 21),
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.sen(fontSize: 20, fontWeight: FontWeight.w600),
          prefixIcon: Icon(prefixIcon, size: 34, color: Colors.black),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black))),
    );
  }
}
