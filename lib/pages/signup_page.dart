import 'package:caremate/components/my_button.dart';
import 'package:caremate/components/my_textfield.dart';
import 'package:caremate/services/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  final Function()? switchPage;
  SignUpPage({super.key, required this.switchPage});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
            child: CircularProgressIndicator(color: ColorAsset.primary)));
    if (passwordController.text == confirmPasswordController.text) {
      try {
        // sign up
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

        // pop loading circle
        if (mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // pop loading circle
        if (mounted) Navigator.pop(context);

        // show alert
        showMessage(e.code);
      }
    } else {
      // pop loading circle
      Navigator.pop(context);

      // show alert
      showMessage("Your passwords don't match");
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
                  // Create Account
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Create",
                          style: GoogleFonts.sen(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text("Account",
                          style: GoogleFonts.sen(
                              height: 0.75,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),

                  const SizedBox(height: 65),

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

                  const SizedBox(height: 25),

                  MyTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      prefixIcon: Icons.lock,
                      obscureText: true),

                  const SizedBox(height: 45),

                  // sign up button
                  GestureDetector(
                      onTap: signUp, child: const MyButton(text: "SIGN UP")),

                  const SizedBox(height: 115),

                  // already have an account? create one!
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?",
                          style: GoogleFonts.sen(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.switchPage,
                        child: Text("Sign In!",
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
