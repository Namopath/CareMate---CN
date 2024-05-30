import 'package:caremate/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/background.png"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: Column(
                      children: [
                        // logo
                        Image.asset("assets/logo.png", width: 256, height: 196),

                        // caremate name
                        Text("CAREMATE",
                            style: GoogleFonts.sen(
                                fontSize: 40, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),

                  // get started button
                  const Padding(
                    padding: EdgeInsets.only(bottom: 35),
                    child: MyButton(text: "GET STARTED!"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
