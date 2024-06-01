import 'package:caremate/pages/connect_page.dart';
import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      FlutterBluePlus.turnOn();
    }
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
        FlutterBluePlus.onScanResults.listen(
          (results) {
            if (results.isNotEmpty) {
              ScanResult r = results.last;
              if (r.advertisementData.advName.contains("CareMate")) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConnectPage(device: r.device)));
              }
            }
          },
          onError: (e) => print(e),
        );
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Error",
                      style: GoogleFonts.sen(
                          fontWeight: FontWeight.bold,
                          color: ColorAsset.error)),
                  content: Text("You're not enable bluetooth",
                      style: GoogleFonts.sen(
                        fontWeight: FontWeight.bold,
                      )),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/background2.png"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Text("Scan Device",
              style: GoogleFonts.sen(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          leading: IconButton(
              onPressed: () async {
                Navigator.pop(context);
                await FlutterBluePlus.stopScan();
              },
              icon: const Icon(Icons.keyboard_arrow_left, size: 29),
              color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            width: double.infinity,
            height: 630,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // scanning image
                Image.asset("assets/scanning.png", width: 250, height: 250),

                const SizedBox(height: 10),

                // scanning for your mate
                Text("Scanning for Mate...",
                    style: GoogleFonts.sen(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorAsset.primary))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
