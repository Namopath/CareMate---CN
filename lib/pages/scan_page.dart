import 'package:caremate/components/l10n.dart';
import 'package:caremate/pages/connect_page.dart';
import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'package:hexcolor/hexcolor.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<ScanResult> devices = [];
  final StreamController<List<ScanResult>> _scanResultsController = StreamController<List<ScanResult>>();

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
              // ScanResult r = results.last;
              // if (r.advertisementData.advName.toLowerCase().contains("caremate")) {
              //   // Navigator.push(
              //   //     context,
              //   //     MaterialPageRoute(
              //   //         builder: (context) => ConnectPage(device: r.device)));
              //   // print(r.advertisementData.advName);
              // }
              _scanResultsController.add(results);
            }
          },
          onError: (e) => print(e),
        );
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.error,
                      style: GoogleFonts.sen(
                          fontWeight: FontWeight.bold,
                          color: ColorAsset.error)),
                  content: Text("You've not enabled bluetooth",
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
          title: Text(AppLocalizations.of(context)!.ble_scan,
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // const SizedBox(height: 40),
                  // // scanning image
                  // Image.asset("assets/scanning.png", width: 250, height: 250),
                  //
                  // // const SizedBox(height: 10),
              
                  Container(
                    width: 300,
                    height: 300,
                    child: StreamBuilder<List<ScanResult>>(stream: _scanResultsController.stream, builder: (context, snapshot){
                      if(snapshot.hasData){
                        final filteredResult = snapshot.data!.where(
                            (result) => result.device.platformName.toLowerCase().contains("caremate")
                        ).toList();
                        // print("Devices: ${filteredResult}");
                        if(filteredResult.isEmpty){
                          return Center(
                            child: Text("We are unable to find CareMate",
                            style: GoogleFonts.sen(
                                fontWeight: FontWeight.bold,
                                color: ColorAsset.error)
                            ),
                          );
                        }
                        return ListView.builder(itemCount: filteredResult.length,
                          itemBuilder: (context, index){
                          final data = filteredResult[index];
                          return Padding(
                            padding: EdgeInsets.fromLTRB(20,10,20,0),
                            child: GestureDetector(
                              onTap: () async{
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ConnectPage(device: data.device)));
                              },
                              child: Container(
                                width: 300,
                                height: 62,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: HexColor('#5490FE'),
                                ),
                                child: ListTile(
                                  title: Text(data.device.platformName.isNotEmpty
                                      ? data.device.platformName
                                      : "Unknown Device",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat_bold',
                                        color: Colors.white
                                    ),
                                  ),
                                  subtitle: Text(data.device.id.id,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat_bold',
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                          },
                        );
                      } else{
                        return Center(
                          child: Text("We are unable to find any devices",
                              style: GoogleFonts.sen(
                                  fontWeight: FontWeight.bold,
                                  color: ColorAsset.error)
                          ),
                        );
                      }
                    }
                    
                    ),
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
