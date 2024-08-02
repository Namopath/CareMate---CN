import 'package:caremate/pages/control_page.dart';
import 'package:caremate/pages/home_page.dart';
import 'package:caremate/pages/pills_page2.dart';
import 'package:caremate/pages/voice_assistant_page.dart';
import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:caremate/services/ble_container.dart';
import 'package:caremate/pages/vidCall.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class Navigation extends StatefulWidget {
  final bool connectionState;
  Navigation({super.key, required this.connectionState});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int index = 0;


  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      HomePage(connectionState: widget.connectionState),
      VoiceAssistantPage(),
      Pills_page(connectionState: widget.connectionState,),
      ControlPage(connectionState: widget.connectionState),
    ];
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/background2.png"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: tabs[index],
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedIconTheme: const IconThemeData(color: ColorAsset.primary),
          unselectedIconTheme: const IconThemeData(color: Colors.black),
          currentIndex: index,
          onTap: (value) {
            // if (value == 3) { // Check if control icon is pressed
            //   isControl(); // Call isControl function
            // }
            setState(() {
              index = value;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 30,
                ),
                label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.mic,
                  size: 30,
                ),
                label: "Voice"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.medical_information_outlined,
                  size: 30,
                ),
                label: "Pills"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.control_camera,
                  size: 30,
                ),
                label: "Control")
          ],

        ),
      ),
    );
  }
}
