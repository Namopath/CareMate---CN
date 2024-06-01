import 'dart:convert';
import 'package:caremate/pages/scan_page.dart';
import 'package:caremate/services/ble_container.dart';
import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ControlPage extends StatelessWidget {
  final bool connectionState;
  const ControlPage({super.key, required this.connectionState});

  @override
  Widget build(BuildContext context) {
    return connectionState
        ? Scaffold(
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
                        GestureDetector(
                          onTap: () async {
                            await context
                                .read<BleContainer>()
                                .writeCharacteristic!
                                .write(utf8.encode("F-1"));
                          },
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorAsset.primary),
                            child: const Icon(Icons.keyboard_arrow_up,
                                size: 44, color: Colors.white),
                          ),
                        ),

                        const SizedBox(height: 35),

                        // arrow right + arrow left + stop button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // arrow right
                            GestureDetector(
                              onTap: () async {
                                await context
                                    .read<BleContainer>()
                                    .writeCharacteristic!
                                    .write(utf8.encode("TL-1"));
                              },
                              child: Container(
                                width: 110,
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorAsset.primary),
                                child: const Icon(Icons.keyboard_arrow_left,
                                    size: 44, color: Colors.white),
                              ),
                            ),

                            // stop button
                            GestureDetector(
                              onTap: () async {
                                await context
                                    .read<BleContainer>()
                                    .writeCharacteristic!
                                    .write(utf8.encode("S-1"));
                              },
                              child: Container(
                                width: 110,
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorAsset.primary),
                                child: const Icon(Icons.stop,
                                    size: 44, color: Colors.white),
                              ),
                            ),

                            // left arrow
                            GestureDetector(
                              onTap: () async {
                                await context
                                    .read<BleContainer>()
                                    .writeCharacteristic!
                                    .write(utf8.encode("TR-1"));
                              },
                              child: Container(
                                width: 110,
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorAsset.primary),
                                child: const Icon(Icons.keyboard_arrow_right,
                                    size: 44, color: Colors.white),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 35),

                        // arrow down
                        GestureDetector(
                          onTap: () async {
                            await context
                                .read<BleContainer>()
                                .writeCharacteristic!
                                .write(utf8.encode("B-1"));
                          },
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorAsset.primary),
                            child: const Icon(Icons.keyboard_arrow_down,
                                size: 44, color: Colors.white),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
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
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  width: double.infinity,
                  height: 570,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      // no ble connection logo
                      Image.asset("assets/logoBLE.png", width: 250),

                      // text
                      Text("Bluetooth is Disconnected",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sen(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[300])),

                      const SizedBox(height: 275),

                      // button
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // device status + connect button
                            Column(children: [
                              // connect device
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ScanPage()));
                                },
                                child: Container(
                                  width: 300,
                                  height: 40,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: ColorAsset.secondary,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // add icon
                                      const Icon(Icons.add_circle_outline,
                                          size: 20, color: Colors.white),

                                      const SizedBox(width: 5),

                                      // text
                                      Text("Connect Device",
                                          style: GoogleFonts.sen(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              )
                            ])
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          );
  }
}
