import 'package:caremate/components/my_button.dart';
import 'package:caremate/components/my_textfield.dart';
import 'package:caremate/services/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogInPage extends StatefulWidget {
  final Function()? switchPage;
  LogInPage({super.key, required this.switchPage});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  void logIn() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
            child: CircularProgressIndicator(color: ColorAsset.primary)));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      showMessage(e.code);
    }
  }

  void showMessage(String content) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Error",
                  style: GoogleFonts.sen(
                      fontWeight: FontWeight.bold, color: ColorAsset.error)),
              content: Text(content,
                  style: GoogleFonts.sen(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK",
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold,
                            color: ColorAsset.primary)))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background2.png"),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 75),
                  // Welcome back
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome",
                          style: GoogleFonts.sen(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text("Back",
                          style: GoogleFonts.sen(
                              height: 0.75,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),

                  const SizedBox(height: 100),

                  // mail + password input
                  MyTextField(
                      controller: emailController,
                      hintText: "E-mail",
                      prefixIcon: Icons.mail,
                      obscureText: false),

                  const SizedBox(height: 25),

                  MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      prefixIcon: Icons.lock,
                      obscureText: true),

                  const SizedBox(height: 45),

                  // login button
                  GestureDetector(
                      onTap: logIn, child: const MyButton(text: "SIGN IN")),

                  const SizedBox(height: 160),

                  // dont have an account? create one!
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Dont't have an account?",
                          style: GoogleFonts.sen(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.switchPage,
                        child: Text("Create one!",
                            style: GoogleFonts.sen(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ColorAsset.primary)),
                      )
                    ],
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
