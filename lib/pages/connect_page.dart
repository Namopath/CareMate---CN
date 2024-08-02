import 'dart:convert';
import 'package:caremate/services/ble_container.dart';
import 'package:caremate/services/colors.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectPage extends StatefulWidget {
  final BluetoothDevice device;
  const ConnectPage({super.key, required this.device});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  @override
  // var currentUser = FirebaseAuth.instance.currentUser;

  // blueprints for ble
  Map<String, dynamic> BleContainerBlueprint = {"write": null, "notify": null};

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
          title: Text(AppLocalizations.of(context)!.connect_ble,
              style: GoogleFonts.sen(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.keyboard_arrow_left, size: 29),
              color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            height: 630,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 5),
                    // would you like to connect caremate to account
                    Text(
                        "Would you like to connect to CareMate#ABC1 with your account?",
                        style: GoogleFonts.sen(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500])),

                    const SizedBox(height: 15),

                    // connect ui
                    Container(
                      width: double.infinity,
                      height: 175,
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // caremate logo + ble name
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/logo.png",
                                  width: 100,
                                  height: 80,
                                ),
                                Text("#ABC1",
                                    style: GoogleFonts.sen(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),

                          // connect icon
                          const Icon(Icons.link,
                              size: 30, color: ColorAsset.primary),

                          // account
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.account_circle_outlined,
                                  size: 80,
                                ),
                                // const SizedBox(height: 5),
                                Text("Admin",
                                    style: GoogleFonts.sen(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),

                // connect button
                GestureDetector(
                  onTap: () async {
                    try {
                      // loading circle
                      showDialog(
                          context: context,
                          builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                  color: ColorAsset.primary)));

                      // stop scan to prevent potential error
                      await FlutterBluePlus.stopScan();

                      // connect to CareMate
                      await widget.device.connect();

                      // set BleContainer device
                      context.read<BleContainer>().changeDevice(widget.device);

                      // discover all services
                      List<BluetoothService> services =
                          await widget.device.discoverServices();

                      // systemize ble services and characteristic
                      for (var service in services) {
                        //service.serviceUuid.toString().length > 4
                        try{
                          if (service.serviceUuid.toString().length > 4) {
                            // discover all characteristics in service
                            List<BluetoothCharacteristic> characteristics =
                                service.characteristics;
                            print("num of char: ${characteristics!.length}");
                            if(characteristics! != null){
                              for (BluetoothCharacteristic characteristic in characteristics!) {
                                // discover descriptor in characteristic
                                // List<BluetoothDescriptor> unFormattedDescriptors =
                                //     characteristic.descriptors;
                                //
                                // // create instance for descriptor
                                // String? descriptor;
                                //
                                // // read descriptor and format
                                // for (var d in unFormattedDescriptors) {
                                //   var descriptorText = await d.read();
                                //   print("Description text: $descriptorText");
                                //   descriptor = utf8.decode(descriptorText);
                                // }
                                //
                                // print("Descriptor: $descriptor");

                                // organize BleContainer
                                if (characteristic.properties.write) {
                                  context.read<BleContainer>().changeWriteCharacteristic(
                                      characteristic);
                                  print("Write characteristic: $characteristic");
                                }
                                else if (characteristic.properties.notify) {
                                  context.read<BleContainer>().changeNotifyCharacteristic(
                                      characteristic);
                                  print("Notify characteristic: $characteristic");
                                }
                              }
                            }else{
                              print("Service ${service.uuid} has no characteristics");
                            }
                            

                          } 
                        }catch (e){
                          print("Try error: $e");
                        }

                      }

                      // write characteristic
                      // context.read<BleContainer>().changeWriteCharacteristic(
                      //     BleContainerBlueprint["write"]);

                      // notify characteristic
                      // context.read<BleContainer>().changeNotifyCharacteristic(
                      //     BleContainerBlueprint["notify"]);

                      // pop loading circle and go back to home page
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } catch (e) {
                      print("Error: $e");

                      await widget.device.disconnect();

                      // pop loading circle
                      Navigator.pop(context);

                      // show error dialog
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(AppLocalizations.of(context)!.error,
                                    style: GoogleFonts.sen(
                                        fontWeight: FontWeight.bold,
                                        color: ColorAsset.error)),
                                content: Text(
                                    "There's an error connecting to CareMate",
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
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: ColorAsset.secondary,
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline,
                            size: 29, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(AppLocalizations.of(context)!.connect,
                            style: GoogleFonts.sen(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
