import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text("Control Center",
            style: GoogleFonts.sen(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // video from the robot
              Container(
                width: 320,
                height: 275,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
              ),

              const SizedBox(height: 15),

              // control panel
              Column(
                children: [
                  // arrow up
                  Container(
                    width: 110,
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: ColorAsset.primary),
                    child: const Icon(Icons.keyboard_arrow_up,
                        size: 44, color: Colors.white),
                  ),

                  const SizedBox(height: 35),

                  // arrow right + arrow left + stop button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // arrow right
                      Container(
                        width: 110,
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: ColorAsset.primary),
                        child: const Icon(Icons.keyboard_arrow_left,
                            size: 44, color: Colors.white),
                      ),

                      // stop button
                      Container(
                        width: 110,
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: ColorAsset.primary),
                        child: const Icon(Icons.stop,
                            size: 44, color: Colors.white),
                      ),

                      // left arrow
                      Container(
                        width: 110,
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: ColorAsset.primary),
                        child: const Icon(Icons.keyboard_arrow_right,
                            size: 44, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // arrow down
                  Container(
                    width: 110,
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: ColorAsset.primary),
                    child: const Icon(Icons.keyboard_arrow_down,
                        size: 44, color: Colors.white),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
